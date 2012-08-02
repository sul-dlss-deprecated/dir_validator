module DirValidator

  def initialize_validator
    return 'spec/fixtures/hummel'
  end
    
  def run_validator(dv)
    dv.dirs('druid_dirs', :re => @druid_re).each do |dir|
      d0 = dir.dir('00', :name => '00')
      d1 = dir.dir('01', :name => '01')
      d2 = dir.dir('02', :name => '02')
      d0.files('tifs', :pattern => '*.tif').each do |tif|
        tif_base = tif.basename('.tif')
        d1.file('jpg', :name => tif_base + '.jpg')
        d2.file('jp2', :name => tif_base + '.jp2')
      end
    end
  end

end
