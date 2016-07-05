module GPhoto2
  # record CameraEvent, type, data
  struct CameraEvent(T)
    property type : FFI::LibGPhoto2::CameraEventType?
    property data : T

    def initialize(@type, @data : T); end
  end
end
