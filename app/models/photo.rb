class Photo < ActiveRecord::Base
  include ModelImage
  has_many :faces, dependent: :destroy

  def face_images(size)
    detected = detect_faces(photo_url, size)
    img = Magick::Image.read(photo_url).first
    results = detected.map do |face|
      { data: face_image(img, face, size), json: face }
    end
    img.destroy!
    results
  end
end
