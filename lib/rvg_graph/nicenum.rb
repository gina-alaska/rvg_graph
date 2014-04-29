# Calculate nice number ranges for graph axis
module RvgGraph
  class Nicenum
    # Thanks Heckbert!
    def self.calc(range, round)
      exponent = Math.log10(range).floor
      fnum = range / (10 ** exponent)
      if round
        if (fnum < 1.5)
          nice_fnum = 1
        elsif fnum < 3
          nice_fnum = 2
        elsif fnum < 7
          nice_fnum = 5
        else
          nice_fnum = 10
        end
      else 
        if fnum <= 1
          nice_fnum = 1
        elsif fnum <= 2
          nice_fnum = 2
        elsif fnum <= 5
          nice_fnum = 5
        else
          nice_fnum = 10
        end
      end    
      return nice_fnum * (10 ** exponent)
    end

    # Floor the date to the closest whole ammount specified.
    def self.date_floor(date, floor)
      case floor
      when "hour"
        newdate = date.change(:sec => 0)
      when "day"
        newdate = date.change(:min => 0)
      when "week"
        newdate = date.beginning_of_day
      when "month"
        newdate = date.beginning_of_week
      when "6.months"
        newdate = date.beginning_of_month
      when "year"
        newdate = date.beginning_of_month
      else
        puts "Unknown floor #{floor} in date_floor function!"
        raise
      end

      return newdate
    end

    # Return nice numbers for date axis.
    def self.nice_date(drange, dmin)
      if drange <= 3600           # 1 hour
        nice_tic_delta = 300      # 5 min
        minor_delta = 30          # 30 sec
        offset = dmin.to_i - self.date_floor(dmin, "hour").to_i
      elsif drange <= 86400       # 1 day
        nice_tic_delta = 3600     # 1 hour
        minor_delta = 600         # 10 min
        offset = dmin.to_i - self.date_floor(dmin, "day").to_i
      elsif drange <= 604800      # 1 week
        nice_tic_delta = 86400    # 1 day
        minor_delta = 10800       # 3 hours
        offset = dmin.to_i - self.date_floor(dmin, "week").to_i
      elsif drange <= 2678400     # 1 month
        nice_tic_delta = 86400    # 1 day
        minor_delta = 43200       # 12 hours
        offset = dmin.to_i - self.date_floor(dmin, "month").to_i
      elsif drange <= 16070400    # 6 months
        nice_tic_delta = 604800   # 1 week
        minor_delta = 86400       # 1 day
        offset = dmin.to_i - self.date_floor(dmin, "6.months").to_i
      else                        # 1 year
        nice_tic_delta = 2678400  # month
        minor_delta = 604800      # 1 week
        offset = dmin.to_i - self.date_floor(dmin, "year").to_i
      end
      return nice_tic_delta, minor_delta, offset
    end
  end
end