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
        if @path != ''
          values[zip_path] = @path
          node.set_attribute('xlink:href', zip_path)
        else
          content.xpath(".//draw:frame[@draw:name='#{name}']").remove
        end
      end
    end

    def values
      @values ||= {}
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
          image.values.each do |entry, path|
            file.output_stream.put_next_entry(entry)
            file.output_stream.write ::File.read(path)
          end
        end
      end # replace_images

      def update_manifest(doc)
        images.each do |image|
          image.values.each do |entry, path|
            extension = entry.split('.').last
            doc.root.add_child %{<manifest:file-entry manifest:full-path="#{entry}" manifest:media-type="image/#{extension}"/>}
          end
        end
      end
    end

  end
end
