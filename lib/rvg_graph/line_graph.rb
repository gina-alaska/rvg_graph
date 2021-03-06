# Draw a line graph from the data
module RvgGraph
  class LineGraph
    extend GraphHelpers

    def self.draw(data, bcord, agg, canvas, data_hash, no_data_value)
      x_min = bcord.xmin
      x_max = bcord.xmax
      y_min = bcord.ymin
      y_max = bcord.ymax

      dstyle = Style.new(data["style"])
      direction = data["direction"]
      range = data["range"].split(",")
      top = range[0].to_f
      bottom = range[1].to_f
      unless data["mark"].nil?
        marks = data["mark"].split(",")
        mark_high = marks[1].to_i if marks[0] == "high"
        mark_low = marks[1].to_i if marks[0] == "low"
      end
      data_top = data["graph_top"]
      data_name = data["name"]

      maxval = agg.maxval.to_f
      minval = agg.minval.to_f
      count = agg.count.to_f

      data["maxval"] = maxval
      data["minval"] = minval

      hard_min = data["hard_min"].nil? ? nil : data["hard_min"].to_f
      hard_max = data["hard_max"].nil? ? nil : data["hard_max"].to_f

      savemax = maxval
      savemin = minval
      minval = hard_min unless hard_min.nil?
      maxval = hard_max unless hard_max.nil?

      oldrange = (maxval - minval).to_f

      ratiox = (x_max - x_min)/count
      newrange = (bottom - top).to_f
      newx = x_min
      newy = 0

      convert = CalcPosition.new(top, bottom, data_top, oldrange, newrange, minval, 0, "line")

      if dstyle.fill_color
        firstnum = data_hash[data_name].first
        firsty = convert.calc(firstnum, false)
        lastnum = data_hash[data_name].last
        lasty = convert.calc(lastnum, false)

        path = "M "
        data_hash[data_name].each do |vdata|
          if check_no_data(vdata, no_data_value)
            newx += ratiox
            next
          end

          newy = convert.calc(vdata, false)
          path += "#{newx.to_i} #{newy.to_i} L "
          newx += ratiox
        end

        if dstyle.fill_to == "top"
          path += "#{x_max.to_i} #{lasty.to_i} L #{x_max.to_i} #{top.to_i}
          L #{x_min.to_i} #{top.to_i} L #{x_min.to_i} #{firsty.to_i} z"
        else
          lasty = top if lasty < top
          path += "#{x_max.to_i} #{lasty.to_i} L #{x_max.to_i} #{bottom.to_i}
               L #{x_min.to_i} #{bottom.to_i} L #{x_min.to_i} 
               #{firsty.to_i} z"
        end
        canvas.path(path).styles(:stroke=>dstyle.fill_color, :fill=>dstyle.fill_color, :stroke_width=>"0.8")
      end

      newx = x_min.to_f
      savx = x_min.to_f
      savy = 0
      dsave = 0

      data_hash[data_name].each_with_index do |vdata, index|
        dsave = vdata
        if check_no_data(vdata, no_data_value)
          savy = 0
          savx = newx
          newx += ratiox
          next
        end

        newy = convert.calc(vdata, false)
        newy = y_min if newy < y_min
        newy = y_max if newy > y_max

        if vdata == savemax and mark_high
          canvas.line(newx, newy-mark_high, newx, newy+mark_high).
              styles(:stroke=>"red")
        end

        if vdata == savemin and mark_low
          canvas.line(newx, newy-mark_low, newx, newy+mark_low).
              styles(:stroke=>"red")
        end

        if savy == 0
          savy = newy
          savx = newx
          newx += ratiox
          next
        else
          canvas.line(savx.to_i, savy.to_i, newx.to_i, newy.to_i).styles(:stroke=>dstyle.color, :stroke_width=>dstyle.line_size, :stroke_linecap=>"round")
        end
        savx = newx
        savy = newy
        newx += ratiox
      end
      savx = x_min if savx < x_min
      savx = x_max if savx > x_max
      savy = y_min if savy < y_min
      savy = y_max if savy > y_max
      newx = x_min if newx < x_min
      newx = x_max if newx > x_max
      canvas.line(savx.to_i, savy.to_i, newx.to_i, savy.to_i).styles(:stroke=>dstyle.color, :stroke_width=>dstyle.line_size, :stroke_linecap=>"round")
    end
  end
end
