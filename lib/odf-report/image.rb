module ODFReport
  class Image < Field
    IMAGE_DIR_NAME = "Pictures"

    attr_accessor :name, :value, :data_field

    def path
      @value
    end

    def replace!(content, data_item=nil)
      @path = get_value(data_item)

      if node = content.xpath(".//draw:frame[@draw:name='#{name}']/draw:image").first
        node.set_attribute('xlink:href', zip_path)
      end
    end

    def path
      @path
    end

    def zip_path
      ::File.join(IMAGE_DIR_NAME, ::File.basename(@path))
    end

    def extension
      ::File.basename(@path).split('.').last
    end


    class << self
      def images
        @@images ||= []
      end

      def add_image(name, path)
        images << Image.new(name: name, path: path)
      end

      def update_images_links(content)
        images.each do |image|
          if node = content.xpath("//draw:frame[@draw:name='#{image.name}']/draw:image").first
            node.set_attribute('xlink:href', image.zip_path)
          end
        end
      end

      # Newer versions of LibreOffice can't open files with duplicates image names.
      def avoid_duplicate_image_names(content)
        nodes = content.xpath("//draw:frame[@draw:name]")

        nodes.each_with_index do |node, i|
          node.attribute('name').value = "#{node.attribute('name').value}_#{i}"
        end
      end

      def write_images(file)
        return if images.empty?

        images.each do |image|
          file.output_stream.put_next_entry(image.zip_path)
          file.output_stream.write ::File.read(image.path)
        end
      end # replace_images

      def update_manifest(doc)
        images.each do |image|
          path      = image.zip_path
          extension = image.extension
          doc.root.add_child %{<manifest:file-entry manifest:full-path="#{path}" manifest:media-type="image/#{extension}"/>}
        end
      end
    end

  end
end
