RSpec.describe "Images" do

  before(:context) do

    @field_01 = Faker::Company.name
    @field_02 = Faker::Name.name

    @itens_01 = Item.get_list(3)

    @image_01 = File.join(Dir.pwd, 'test', 'templates', 'rails.png')

    report = ODFReport::Report.new("spec/specs.odt") do |r|

      r.add_image(:image_01, @image_01)

      r.add_table('TABLE_01', @itens_01) do |t|
        t.add_column(:column_01, :id)
        t.add_column(:column_02, :name)
        t.add_image(:image_02,   @image_01)
      end

      r.add_section('SECTION_01', @itens_01) do |t|
        t.add_field(:s01_field_01, :id)
        t.add_field(:s01_field_02, :name)
      end

    end

    report.generate("spec/result/specs.odt")

    @data = Inspector.new("spec/result/specs.odt")

  end


  it "simple images replacement" do
    # It increases "_<index>" to image names after replace them.
    expect(@data.text).to include("image_01_0")
  end

end
