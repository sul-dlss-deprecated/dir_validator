describe DirValidator::Quantity do

  def new_q(spec)
    return DirValidator::Quantity.new(spec)
  end

  before(:all) do
    @inf = 1.0 / 0
  end

  it "can initialize a Quantity" do
    new_q('1').should be_kind_of DirValidator::Quantity
  end

  describe "should parse valid specs correctly" do
    
    it "0+" do
      ['*', '0+'].each do |spec|
        q = new_q(spec)
        q.min_n.should     == 0
        q.max_n.should     == @inf
        q.max_index.should == -1
      end
    end

    it "1+" do
      ['+', '1+'].each do |spec|
        q = new_q(spec)
        q.min_n.should     == 1
        q.max_n.should     == @inf
        q.max_index.should == -1
      end
    end

    it "0-1" do
      ['?', '0-1'].each do |spec|
        q = new_q(spec)
        q.min_n.should     == 0
        q.max_n.should     == 1
        q.max_index.should == 0
      end
    end

    it "n+" do
      [3, 99].each do |n|
        q = new_q("#{n}+")
        q.min_n.should     == n
        q.max_n.should     == @inf
        q.max_index.should == -1
      end
    end

    it "n" do
      [3, 99].each do |n|
        q = new_q("#{n}")
        q.min_n.should     == n
        q.max_n.should     == n
        q.max_index.should == n - 1
      end
    end

    it "m-n" do
      [[1,3], [90,99]].each do |m,n|
        q = new_q("#{m}-#{n}")
        q.min_n.should     == m
        q.max_n.should     == n
        q.max_index.should == n - 1
      end
    end

  end

  it "should raise ArgumentError for invalid specs" do
    bad_specs = [ '', '1-0', ' 33', '33 ', '-2', '1?' ]
    bad_specs.each do |spec|
      expect { new_q(spec) }.to raise_error(ArgumentError)
    end
  end

end
