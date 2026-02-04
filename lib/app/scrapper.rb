require 'nokogiri'
require 'open-uri'
require 'json'
require 'csv'
require 'google_drive'

class Scrapper
  attr_accessor :final_data

  def initialize
    @final_data = []
    @base_url = "https://lannuaire.service-public.gouv.fr"
    @vdo_url = "#{@base_url}/navigation/ile-de-france/val-d-oise/mairie"
  end

  # 1. Récupère les liens des mairies
  def get_townhall_urls
    page = Nokogiri::HTML(URI.open(@vdo_url, "User-Agent" => "Mozilla/5.0"))
    urls = []
    page.css('main ul li a').each do |link|
      href = link['href']
      urls << (href.start_with?("http") ? href : @base_url + href)
    end
    urls.uniq
  end

  # 2. Récupère l'email sur la page d'une mairie
  def get_townhall_email(townhall_url)
    begin
      page = Nokogiri::HTML(URI.open(townhall_url, "User-Agent" => "Mozilla/5.0"))
      city_name = page.css('h1').text.strip
      email = page.to_s.match(/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i).to_s
      { city_name => email }
    rescue
      nil
    end
  end

  # 3. Sauvegarde JSON
  def save_as_JSON
    Dir.mkdir("db") unless Dir.exist?("db")
    File.open("db/emails.json", "w") do |f|
      f.write(JSON.pretty_generate(@final_data))
    end
  end

  # 4. Sauvegarde CSV
  def save_as_csv
    Dir.mkdir("db") unless Dir.exist?("db")
    CSV.open("db/emails.csv", "wb") do |csv|
      @final_data.each do |hash|
        hash.each { |city, email| csv << [city, email] }
      end
    end
  end

  # 5. Sauvegarde Google Spreadsheet
  def save_as_spreadsheet
    # Connexion via le fichier config.json à la racine
    session = GoogleDrive::Session.from_config("config.json")
    # Trouve le fichier par son nom exact
    ws = session.spreadsheet_by_title("Mairies Val d'Oise").worksheets[0]
    
    @final_data.each_with_index do |hash, i|
      hash.each do |city, email|
        ws[i + 1, 1] = city
        ws[i + 1, 2] = email
      end
    end
    ws.save
  end

  # 6. Lancement du programme
  def perform
    puts "1. Collecte des données..."
    urls = get_townhall_urls[0..15] # On limite à 16 pour tester vite
    
    urls.each_with_index do |url, index|
      print "\rTraitement : #{index + 1}/#{urls.size}"
      data = get_townhall_email(url)
      @final_data << data if data && !data.values.first.empty?
      sleep(0.1)
    end

    puts "\n2. Sauvegarde des fichiers locaux (JSON/CSV)..."
    save_as_JSON
    save_as_csv

    puts "3. Tentative de sauvegarde Google Spreadsheet..."
    begin
      save_as_spreadsheet
      puts "✅ Succès : Spreadsheet mis à jour."
    rescue Exception => e
      puts "❌ ERREUR SPREADSHEET : #{e.message}"
    end
    puts "Terminé."
  end
end