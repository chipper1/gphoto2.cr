module GPhoto2
  class CameraList; end

  class Entry
    @camera_list : CameraList
    @index : Int32

    def initialize(@camera_list, @index)
    end

    def name
      get_name
    end

    def value
      get_value
    end

    private def get_name
      GPhoto2.check! FFI::LibGPhoto2.gp_list_get_name(@camera_list, @index, out ptr)
      !ptr ? nil : String.new ptr
    end

    private def get_value
      GPhoto2.check! FFI::LibGPhoto2.gp_list_get_value(@camera_list, @index, out ptr)
      !ptr ? nil : String.new ptr
    end
  end
end
