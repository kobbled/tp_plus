module TPPlus
  module Motion

    Struct.new("TConfig", :flips, :turns)
    Struct.new("TPose", :coord, :orient, :config)
    Struct.new("TJpos", :joints)

    DEFAULT_POSE = Struct::TPose.new([0,0,0],[0,0,0], Struct::TConfig.new(['N','D','B'], [0,0,0]))
    DEFAULT_JPOS = Struct::TJpos.new([0,0,0,0,0,0,0,0,0])
  end
end