# Draw background dividers on graph
module RvgGraph
  class Dividers
    def self.draw(bcord, data_object, canvas, data_hash, no_data)
      data_object.each do |data|
        agg = Agg.new(data_hash, data["name"], no_data)
        next if data["axis"].nil?

        data["axis"].each do |axis|
          if axis["dividers"]
            divider_object = axis["dividers"]
            dstyle = Style.new(divider_object["style"])
            x_min = bcord.xmin
            x_max = bcord.xmax
            top = bcord.ymin
            bottom = bcord.ymax
            major_tics = divider_object["major"].to_i
            data_top = data["graph_top"]

            dmax = agg.maxval.to_f
            dmin = agg.minval.to_f

            # date axis
            if axis["label"]["units"] == "date"
              dmin = agg.capture_min
              dmax = agg.capture_max
            end

            # Find nice number range for axis tics/labels
            offset = 0
            unless axis["label"]["units"] == "date"
              nice_range = Nicenum.calc(dmax - dmin, false)
              nice_tic_delta = Nicenum.calc(nice_range/(major_tics - 1), true).to_f
              nice_min = (dmin / nice_tic_delta).floor * nice_tic_delta
              nice_max = (dmax / nice_tic_delta).ceil * nice_tic_delta
              minor_delta = nice_tic_delta / minor_tics unless minor_tics.nil?
              offset = nice_min - dmin
            else
              drange = dmax.to_i - dmin.to_i
              nice_tic_delta, minor_delta, offset = Nicenum.nice_date(drange, dmin)
              nice_min = (dmin.to_i / nice_tic_delta).floor * nice_tic_delta
              nice_max = (dmax.to_i / nice_tic_delta).ceil * nice_tic_delta
            end

            if axis["label"]["units"] == "date"
              dmin = dmin.to_i
              dmax = dmax.to_i
            end

            convert = CalcPosition.new(x_min, x_max, data_top, dmax-dmin, x_max-x_min, dmin, offset, axis["label"]["units"])

            pos = nice_min
            while pos <= nice_max do
              dpos = convert.calc_axis(pos, false)
              # draw divider lines
              if dpos > x_min and dpos < x_max
                canvas.line(dpos.to_i, top.to_i, dpos.to_i, bottom.to_i).styles( :stroke=>dstyle.color, :stroke_width=>dstyle.line_size, :stroke_dasharray=>dstyle.line_type, :fill=>"none")
              end

              pos += nice_tic_delta
              break if pos > dmax 
            end
          end
        end
      end    
    end
  end
end