RSpec.describe "Images" do

  before(:context) do

    @field_01 = Faker::Company.name
    @field_02 = Faker::Name.name

    @image_01 = File.join(Dir.pwd, 'test', 'templates', 'rails.png')
    @image_02 = File.join(Dir.pwd, 'test', 'templates', 'piriapolis.jpg')

    @itens_01 = Item.get_list(3)

    @itens_01[0].image = @image_01
    @itens_01[1].image = @image_02
    @itens_01[2].image = @image_01 

    report = ODFReport::Report.new("spec/specs.odt") do |r|

      r.add_image(:image_01, @image_01)

      r.add_table('TABLE_01', @itens_01) do |t|
        t.add_column(:column_01, :id)
        t.add_column(:column_02, :name)
        t.add_image(:image_02, :image)
      end

      r.add_section('SECTION_01', @itens_01) do |t|
        t.add_field(:s01_field_01, :id)
        t.add_field(:s01_field_02, :name)
        t.add_image(:image_03, :image)
      end

    end

    report.generate("spec/result/specs.odt")

    @data = Inspector.new("spec/result/specs.odt")

  end

  it "should add images to manifest" do
    expect(@data.manifest).to include('Pictures/rails.png')
  end

  it "simple images replacement" do
    image = @data.xml.xpath("//draw:frame[@draw:name='image_01_0']/draw:image").first
    expect(image.attr('xlink:href')).to eq(File.join('Pictures', File.basename(@image_01)))
  end
  
  context "columns image replacement" do
    it "should works in the first row" do
      image = @data.xml.xpath("//draw:frame[@draw:name='image_02_1']/draw:image").first
      expect(image.attr('xlink:href')).to eq(File.join('Pictures', File.basename(@image_01)))
    end

    it "should works in the second row" do
      image = @data.xml.xpath("//draw:frame[@draw:name='image_02_2']/draw:image").first
      expect(image.attr('xlink:href')).to eq(File.join('Pictures', File.basename(@image_02)))
    end

    it "should works with a block" do
      report = ODFReport::Report.new("spec/specs.odt") do |r|

        r.add_image(:image_01, @image_01)

        r.add_table('TABLE_01', @itens_01) do |t|
          t.add_column(:column_01, :id)
          t.add_column(:column_02, :name)
          t.add_image(:image_02) { |i| i.image }
        end

        r.add_section('SECTION_01', @itens_01) do |t|
          t.add_field(:s01_field_01, :id)
          t.add_field(:s01_field_02, :name)
        end

      end
      report.generate("spec/result/specs.odt")
      @data = Inspector.new("spec/result/specs.odt")

      image = @data.xml.xpath("//draw:frame[@draw:name='image_02_3']/draw:image").first
      expect(image.attr('xlink:href')).to eq(File.join('Pictures', File.basename(@image_01)))
    end
  end

  context "section image replacement" do
    it "should works" do
      image = @data.xml.xpath("//draw:frame[@draw:name='image_03_4']/draw:image").first
      expect(image.attr('xlink:href')).to eq(File.join('Pictures', File.basename(@image_01)))
    end
  end

end
