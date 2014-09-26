##
# Update an Offer with Google infos
class UpdateOffer
  extend Surrounded::Context

  initialize :offer

  def self.full_update_all
    puts 'Full google update for all offers'
    ::Offer.all.each do |offer|
      UpdateOffer.full(offer)
    end
  end

  shortcut_triggers

  def full
    offer.update_infos
    offer.update_rating
    offer.save!
  end
  trigger :full

  def rating
    offer.update_rating
    offer.save!
  end
  trigger :rating

  def place_id
    offer.update_place_id
    offer.save!
  end
  trigger :place_id

  role :offer do
    def update_infos
      if google_place
        self.google_place_id = google_place.place_id
        self.latitude = google_place.lat
        self.longitude = google_place.lng
        self.street = [google_place.street, google_place.street_number].join(' ')
        self.city = [google_place.postal_code, google_place.city].join(' ')
      end
    end

    def update_rating
      if google_place
        self.google_place_rating = google_place.rating
      end
    end

    def update_place_id
      if google_place
        self.google_place_id = google_place.place_id
      end
    end

    ##
    # Use only name to find places. Worse results when combined with city
    def google_place
      if google_place_id
        @google_place ||= GooglePlaces::Client.new(ENV['GOOGLE_API_KEY']).spot(google_place_id)
      else
        @google_place ||= GooglePlaces::Client.new(ENV['GOOGLE_API_KEY']).spots_by_query(name).first
      end
    end
  end
end