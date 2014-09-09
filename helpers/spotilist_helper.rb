class Spotilist < Sinatra::Base
  helpers do

    def duration_in_minutes(time_in_seconds)
      duration(time_in_seconds, 'm')
    end

    def duration_in_hours(time_in_seconds)
      duration(time_in_seconds, 'h')
    end

    def duration(time_in_seconds, format)
      mm, ss = time_in_seconds.to_i.divmod(60)
      case format
      when 'h'
        hh, mm = mm.divmod(60)
        mm = add_leading_zero(mm)
        hh = add_leading_zero(hh)
        "#{hh}:#{mm}"
      when 'm'
        ss = add_leading_zero(ss)
        mm = add_leading_zero(mm)
        "#{mm}:#{ss}"
      else
        time_in_seconds
      end
    end

    def get_tracks(object, from=0, to=20)
      object.tracks[0, 20].map(&:load)
    end
  end
end
