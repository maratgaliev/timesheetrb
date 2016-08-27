class TimesheetGraph

  def initialize(alpha, args, data = nil)
    @ddata = {}
    @mdata = {}
    @format = []
    @colors = ['default', 'lorem', 'ipsum', 'dolor', 'sit']

    default_args = {
        id: 'timesheet',
        theme: nil,
        alpha_first: 1,
        omega_first: 1,
        line: nil,
        line_text: nil,
        format: {
            segment_des: "%s to %s",
            timesheet_format: nil,
            date_format: nil
        }
    }

    args = default_args.merge!(args)
    @all_segment = ''
    @alpha = alpha
    @data = data

    @id = args[:id]
    @theme = args[:theme]
    @alpha_first = args[:alpha_first]
    @omega_base = args[:omega_base]
    @omega_first = args[:omega_first]
    @line = args[:line]
    @line_text = args[:line_text]
    @format = args[:format]
    @one_alpha = 100 / @alpha.size
    @one_omega = @one_alpha / @omega_base
    create_all_segments
  end

  def start_segment(alpha, omega)
    start_segment = ( ( ( (alpha.to_i - @alpha_first + 1) - 1) * @one_alpha ) + ( ( omega.to_i - @omega_first)  * @one_omega))
    if start_segment < 0
      start_segment = 0
    end
    return start_segment
  end

  def end_segment(alpha, omega)
    end_segment = ( ( ( (alpha.to_i - @alpha_first + 1) - 1) * @one_alpha ) + ( ( omega.to_i - @omega_first)  * @one_omega) )
    if end_segment > 100
      end_segment = 100
    end
    return end_segment
  end

  def get_line_data
    line = @line.split('-')
    return start_segment(line[0], line[1])
  end

  def section_title
    str = ''
    @alpha.each do |alpha|
        str += '<section><div>'+ alpha + '</div></section>'
    end
    str
  end

  def calcul_timesheet(level_key, segment)

    if segment['start'][1].to_i > (@omega_base + @omega_first) || segment['end'][1].to_i > (@omega_base + @omega_first)
      puts 'Greater'
    end

    start_segment = start_segment(segment['start'][0].to_i, segment['start'][1].to_i)
    end_segment = end_segment(segment['end'][0].to_i, segment['end'][1].to_i)
    return_var = Array.new

    if segment['end'][0].to_i < segment['start'][0].to_i || (segment['end'][0].to_i == segment['start'][0].to_i && segment['end'][1].to_i < segment['start'][1].to_i)
      segment['head_segment'] = true
      segment['marginleft'] = 0
      segment['width'] = end_segment
      return_var.push(segment)
      segment['head_segment'] = false
      segment['marginleft'] = start_segment
      segment['width'] = 100 - start_segment
    else
      segment['head_segment'] = true
      segment['marginleft'] = start_segment
      segment['width'] = end_segment - start_segment
    end
    return_var.push(segment)
    return return_var
  end


  def create_all_segments
    i = 0
    @data.each do |level_key, periods|
      i += 1
      color = @colors[i % 5]
      segments = Array.new
      m_periods = Array.new
      #m_period = Array.new
      periods.each do |period|
        m_period = {
            'title'=> level_key,
            'color' => color,
            'start' => period['start'].split('-'),
            'end' =>  period['end'].split('-'),
        }
        m_periods << m_period
        tab = calcul_timesheet(level_key, m_period)
        tab.each do |t|
          segments << t
        end
      end
      @ddata[level_key] = segments
      @mdata[level_key] = m_periods
    end
  end



  def get_segment(key, segment, head_level)
    displayDate = get_format(segment)
    html = <<-eos
      <div class="segment">
      <div style="margin-left: #{segment['marginleft']}%;">
    eos
    if head_level
      html += "<span class='label'>#{segment['title']}</span>"
    end
    if segment['head_segment']
      html += "<span class='date'>#{displayDate}</span>&nbsp;"
    end
    html += <<-eos
      </div>
        <div style="margin-left: #{segment['marginleft']}%; width: #{segment['width']}%;position:relative;" class="bubble bubble-#{segment['color']}" data-duration="6"></div>
      </div>
    eos
		return html
  end


  def get_display_data
    html = ''
    @ddata.each do |key, level|
        head_level = true
        html += '<li>'
        level.each do |segment|
          html += get_segment(key, segment, head_level)
          head_level = false
        end
    html += '</li>'
    end
    return html
  end

  def get_format(segment, mobile = false)
    displayDate = ''
    if !@format.empty? && @format['timesheet_format'] && @format['date_format']
      startdate = date(@format['date_format'], strtotime( segment['start'][0] + '-' + segment['start'][1] ) )
      enddate = date(@format['date_format'], strtotime( segment['end'][0] +'-' + segment['end'][1] ) )
      displayDate = sprintf( @format['segment_des'], startdate, enddate)
    else
      startA = get_alpha_title(segment['start'][0])
      endA = get_alpha_title(segment['end'][0])
			if !mobile && segment['start'][0] == segment['end'][0]
				displayDate = startA + " " + segment['start'][1] + ' to ' + segment['end'][1]
			else
				displayDate = startA + '-' + segment['start'][1] + ' to ' + endA + '-' + segment['end'][1]
			end
		end
		return displayDate
  end

  def get_alpha_title(alphaN)
    if @alpha.include?( alphaN.to_i - @alpha_first)
        return @alpha[ alphaN.to_i - @alpha_first ]
    else
        return alphaN
    end
  end

  def get_display_data_mobile
    html = ''
    @mdata.each do |key, segments|
      html += '<li>'
      html += '<div class="label '+ segments[0]['color'] + '" >' + key + '</div><div class="dates ' + segments[0]['color'] + '">'
      segments.each do |segment|
        html += '<div class="date">' + get_format( segment, true ) + '</div>'
      end
      html += '</div></li>'
    end
    return html
  end






  def display
    html = get_display_data
    html_mobile = get_display_data_mobile
    style = ''
    style += <<-eos
      <style>
        ##{@id} div.scale section{
        width:#{@one_alpha}%;
    eos

    if !@line.empty?
      style += <<-eos
        @media screen and (min-width: 500px) {
            ##{@id} .line{
            display:block;
          }
          ##{@id} .line section {
            left:#{get_line_data()}%;
          }
          ##{@id} .line section:after {
            content : "\25B2 #{@line_text}";
          }
        }
        </style>
      eos
    end

    style += <<-eos
      <div class="timesheet color-scheme-default #{@theme}" id="#{@id}">
          <!-- A line -->
          <div class="line">
            <section><div></div></section>
          </div>
          <!-- Section -->
          <div class="scale">
            #{section_title}
          </div>
          <!-- end section -->

          <!-- data is the default and appear for reolution more than 500px -->
          <ul class="data">
            #{html}
          </ul>
          <!-- mdata is for mobile and appear for reolution less than 500px -->
          <ul class="mdata">
            #{html_mobile}
          </ul>
        </div>
      eos
    style.html_safe
    end
end