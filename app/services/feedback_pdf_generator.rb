class FeedbackPdfGenerator
  def initialize(user, responses)
    @user = user
    @responses = responses
    @pdf = Prawn::Document.new
  end
  
  def generate
    add_header
    add_summary
    add_responses
    @pdf.render
  end
  
  private
  
  def add_header
    @pdf.text "Anonymous Feedback Report", size: 24, style: :bold
    @pdf.text "Generated: #{Time.current.strftime('%B %d, %Y')}", size: 12
    @pdf.text "For: #{@user.display_name}", size: 12
    @pdf.move_down 20
  end
  
  def add_summary
    @pdf.text "Summary", size: 18, style: :bold
    @pdf.move_down 10
    
    summary_data = [
      ["Total Responses", @responses.count.to_s],
      ["Average Length", "#{@responses.average(:content_length).to_i} characters"],
      ["Date Range", date_range]
    ]
    
    @pdf.table(summary_data, width: 500) do
      row(0..2).font_style = :bold
      cells.borders = []
      cells.padding = 5
    end
    
    @pdf.move_down 20
  end
  
  def add_responses
    @pdf.text "Individual Feedback", size: 18, style: :bold
    @pdf.move_down 10
    
    @responses.each_with_index do |response, index|
      # Check if we need a new page
      @pdf.start_new_page if @pdf.cursor < 150 && index > 0
      
      # Response header with colored bar
      @pdf.stroke_color "4F46E5"
      @pdf.stroke do
        @pdf.line_width 3
        @pdf.vertical_line @pdf.cursor, @pdf.cursor - 2, at: 0
      end
      @pdf.stroke_color "000000"
      
      @pdf.indent(10) do
        @pdf.text "Response ##{index + 1}", size: 14, style: :bold
        @pdf.text "Received: #{response.fuzzy_time}", size: 10, color: "666666"
        @pdf.text "Length: #{response.content_length} characters", size: 10, color: "666666"
        @pdf.move_down 8
        
        # Add question responses if they exist
        if response.question_responses.present? && response.question_responses.any?
          @pdf.text "Question Responses:", size: 11, style: :bold
          @pdf.move_down 5
          
          response.feedback_request.questions.each do |question|
            answer = response.question_responses[question['id'].to_s]
            if answer.present?
              @pdf.fill_color "F3F4F6"
              @pdf.fill_rectangle [0, @pdf.cursor], @pdf.bounds.width - 10, (@pdf.height_of(answer, width: @pdf.bounds.width - 30) + 20)
              @pdf.fill_color "000000"
              
              @pdf.move_down 5
              @pdf.indent(5) do
                @pdf.text question['text'], size: 9, style: :bold, color: "6B7280"
                @pdf.move_down 3
                @pdf.text answer, size: 10, align: :left
              end
              @pdf.move_down 8
            end
          end
        end
        
        # Overall feedback
        @pdf.text "Overall Feedback:", size: 11, style: :bold
        @pdf.move_down 5
        @pdf.text response.content, size: 11, align: :left
      end
      
      @pdf.move_down 15
      
      # Start new page if less than 100 points remaining
      @pdf.start_new_page if @pdf.cursor < 100 && index < @responses.count - 1
    end
  end
  
  def date_range
    return "N/A" if @responses.empty?
    
    first = @responses.order(:created_at).first
    last = @responses.order(:created_at).last
    
    if first.created_at.to_date == last.created_at.to_date
      first.created_at.strftime("%B %d, %Y")
    else
      "#{first.created_at.strftime('%b %d')} - #{last.created_at.strftime('%b %d, %Y')}"
    end
  end
end
