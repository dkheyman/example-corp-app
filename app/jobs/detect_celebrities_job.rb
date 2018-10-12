class DetectCelebritiesJob
    include SuckerPunch::Job
  
    def perform(sneaker_id)
        begin
            @sneaker = Sneaker.find(sneaker_id)

            client = Aws::Rekognition::Client.new
            resp = client.recognize_celebrities({
                    image: { bytes: @sneaker.sneaker_image.download }
            })

            resp.celebrity_faces.each do |label|
                puts "#{label.name}-#{label.match_confidence.to_i}"

                @tag = Tag.new
                @tag.name = label.name
                @tag.confidence = label.match_confidence
                @tag.source = "Rekognition - Recognize Celebrities"
                @tag.sneaker = @sneaker
                @tag.save

            end
            rescue StandardError => e
                puts("--------------------------------- [ERROR] ---------------------------------")
                puts(e)
                @tag = Tag.new
                @tag.name = "Error"
                @tag.sneaker = @sneaker
                @tag.save
        end
    end

end