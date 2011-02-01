require 'open-uri'
require 'fileutils'

namespace :portal do
  namespace :setup do
    
    nces_dir = File.join(RAILS_ROOT, 'config', 'nces_data')
    school_layout_file = File.join(nces_dir, 'psu061blay.txt')
    district_layout_file = File.join(nces_dir, 'pau061blay.txt')

    # 
    # task: portal:setup:download_nces_data
    # Download NCES CCD data files from NCES website
    # 
    desc 'Download NCES CCD data files from NCES website'
    task :download_nces_data do
      puts <<-HEREDOC

Download District and School NCES Common Core of Data files from the 
NCES website: http://nces.ed.gov/ccd/data/zip/

      HEREDOC
      FileUtils.mkdir_p(nces_dir) unless File.exists?(nces_dir)
      Dir.chdir(nces_dir) do
        files = [
          'http://nces.ed.gov/ccd/data/zip/sc061bai_dat.zip',
          'http://nces.ed.gov/ccd/data/zip/sc061bkn_dat.zip',
          'http://nces.ed.gov/ccd/data/zip/sc061bow_dat.zip',
          'http://nces.ed.gov/ccd/pdf/psu061bgen.pdf',
          'http://nces.ed.gov/ccd/data/txt/psu061blay.txt',
          'http://nces.ed.gov/ccd/data/zip/ag061b_dat.zip',
          'http://nces.ed.gov/ccd/pdf/pau061bgen.pdf',
          'http://nces.ed.gov/ccd/data/txt/pau061blay.txt'
        ]
        files.each do |url_str|
          if File.exists?(File.basename(url_str))
            puts "  data file already exists: #{File.basename(url_str)}"
          else
            cmd = "wget -q -nc #{url_str}"
            puts cmd
            system(cmd)
            if url_str =~ /\.zip\z/
              cmd = "unzip -o #{File.basename(url_str)}"
              puts cmd
              system(cmd)
            end
          end
        end
      end
      puts
    end

    # 
    # task: portal:setup:generate_nces_tables_migration
    # Generate migration file for nces tables
    #
    desc 'Generate migration file for nces tables'
    task :generate_nces_tables_migration => :environment do
      parser = NcesParser.new(district_layout_file, school_layout_file, 2006)
      parser.create_tables_migration
    end

    # 
    # task: portal:setup:generate_nces_indexes_migration
    # Generate migration file for nces indexes
    # 
    desc 'Generate migration file for nces indexes'
    task :generate_nces_indexes_migration => :environment do
      parser = NcesParser.new(district_layout_file, school_layout_file, 2006)
      parser.create_indexes_migration
    end
    
    desc 'Import NCES data from files: config/nces_data/* -- uses APP_CONFIG[:states_and_provinces] if defined to filter on states'
    task :import_nces_from_files => :environment do
      puts <<HEREDOC

Import NCES District and School Common Core of Data from files: config/nces_data/*

Import process uses APP_CONFIG[:states_and_provinces] if defined to filter on states.

  Example from file: config/settings.yml:

    states_and_provinces:
      - RI

HEREDOC

      states_and_provinces = APP_CONFIG[:states_and_provinces]
      district_data_fnames = %w{ag061b.dat}
      district_data_fpaths = district_data_fnames.collect { |f| File.join(nces_dir, f) }
      school_data_fnames = %w{Sc061bai.dat Sc061bkn.dat Sc061bow.dat}
      school_data_fpaths = school_data_fnames.collect { |f| File.join(nces_dir, f) }
      parser = NcesParser.new(district_layout_file, school_layout_file, 2006, states_and_provinces)
      parser.load_db(district_data_fpaths, school_data_fpaths)
    end

    #
    # task: portal:setup:create_districts_and_schools_from_nces_data
    # Create districts and schools from NCES records for States listed in settings.yml
    # 
    desc 'Create districts and schools from NCES records for States listed in settings.yml'
    task :create_districts_and_schools_from_nces_data => :environment do
      states_and_provinces = APP_CONFIG[:states_and_provinces]
      active_school_levels = APP_CONFIG[:active_school_levels]

      puts <<-HEREDOC

Creating districts and schools from NCES records for States listed in settings.yml

Active School Levels: #{active_school_levels.join(', ')}

Set these for this application in config/settings.yml.

  Example from file: config/settings.yml:

    active_school_levels: 
      - "2"
      - "3"

NCES School levels are used as the keys.
 
The following codes were calculated from the school's corresponding GSLO and GSHI values: 
  1 = Primary (low grade = PK through 03; high grade = PK through 08)
  2 = Middle (low grade = 04 through 07; high grade = 04 through 09)
  3 = High (low grade = 07 through 12; high grade = 12 only
  4 = Other (any other configuration not falling within the above three categories, including ungraded)

      HEREDOC
      
      portal_school_field_names = [:name, :uuid, :state, :leaid_schoolnum, :zipcode, :district_id, :nces_school_id]
      portal_district_field_names = [:name, :uuid, :state, :leaid, :zipcode, :nces_district_id]
      import_options = { :validate => false }

      states_and_provinces.each do |state|
        count = 0
        school_values = []
        district_values = []
        state_province_str = "#{state}, #{StatesAndProvinces::STATES_AND_PROVINCES[state]}"
        nces_districts = Portal::Nces06District.find(:all, :conditions => { :MSTATE => state }, :select => "id, NAME, LEAID, LZIP, LSTATE")
        if nces_districts.empty?
          puts "\n*** No NCES districts found in state/province: #{state_province_str}"
        else
          puts "\n*** Processing #{nces_districts.length} NCES districts in: #{state_province_str}"
          count = 0
          nces_districts.each do |nces_district|
            nces_schools = Portal::Nces06School.find(:all, :conditions => { :nces_district_id => nces_district.id }, :select => "LEVEL")
            nces_school_levels = nces_schools.collect { |s| s.LEVEL }
            count += 1
            if count % 25 == 0
              print '.'
              STDOUT.flush
            end
            if (nces_school_levels & active_school_levels).empty?
              # puts "\nskipping district: #{nces_district.capitalized_name}"
              # puts "  district schools levels: #{nces_school_levels.join(', ')}"
            else
              # new_districts << Portal::District.new(:name => nces_district.capitalized_name, :nces_district_id => nces_district.id)
              district_values << [nces_district.capitalized_name, UUIDTools::UUID.timestamp_create.to_s, nces_district.LSTATE, nces_district.LEAID, nces_district.LZIP, nces_district.id]
            end
          end
          # portal_districts = Portal::District.import(new_districts, :synchronize => new_districts)
          Portal::District.import(portal_district_field_names, district_values, import_options)
          portal_districts = Portal::District.find(:all, :conditions => { :state => state }, :select => "id, nces_district_id, state")
          puts "\ncreated #{portal_districts.length} districts"
          count = 0
          portal_districts.each do |portal_district|
            nces_schools = Portal::Nces06School.find(:all, :conditions => { :nces_district_id => portal_district.nces_district_id }, :select => "id, nces_district_id, NCESSCH, LZIP,SCHNAM, LEVEL")
            nces_school_levels = nces_schools.collect { |s| s.LEVEL }
            if count % 10 == 0
              print '.'
              STDOUT.flush
            end
            unless (nces_school_levels & active_school_levels).empty?          
              nces_schools.each do |nces_school|
                school_values << [nces_school.capitalized_name, UUIDTools::UUID.timestamp_create.to_s, portal_district.state, nces_school.NCESSCH, nces_school.LZIP,  portal_district.id, nces_school.id]
              end
            end
          end
          Portal::School.import(portal_school_field_names, school_values, import_options)
          portal_schools = Portal::School.find(:all, :conditions => { :state => state }, :select => "id")
          puts "\ncreated #{portal_schools.length} schools"
        end
      end
    end
  end
end
