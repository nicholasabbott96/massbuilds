class Development
  module ModelCallbacks
    extend ActiveSupport::Concern

    included do
      before_save :clean_zip_code
      before_save :associate_place
      before_save :determine_mixed_use
      before_save :cache_street_view
      before_save :update_walk_score
      before_save :estimate_employment

      private

      def clean_zip_code
        zip_code.to_s.gsub!(/\D*/, '') # Only digits
      end

      def associate_place
        if location_fields_changed? || new_record?
          places = Place.contains(lat: latitude, lon: longitude)
          if places.empty?
            Airbrake.notify 'No place found' if defined?(Airbrake)
            self.place = nil
          else
            self.place = places.first
          end
        end
      end

      def determine_mixed_use
        if mixed_use?
          self.mixed_use = mixed_use?
        end
      end

      def cache_street_view
        if street_view_fields_changed? || new_record?
          self.street_view_image = street_view.image(cached: false)
        end
      end

      def update_walk_score
        if location_fields_changed? || new_record?
          self.walkscore = WalkScore.new(lat: latitude, lon: longitude).to_h
        end
      end

      def estimate_employment
        self.estemp = EmploymentEstimator.new(self).estimate
      end

      def location_fields_changed?
        [:latitude, :longitude, :street_view_latitude, :street_view_longitude].select { |f|
          send("#{f}_changed?")
        }.any?
      end

      def street_view_fields_changed?
        [:latitude, :longitude, :pitch, :heading].select { |field|
          send("street_view_#{field}_changed?")
        }.any?
      end

    end

  end
end
