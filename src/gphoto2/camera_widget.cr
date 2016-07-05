require "./struct"

module GPhoto2
  abstract class CameraWidget
    class NotImplementedError < Exception; end

    include GPhoto2::Struct(FFI::LibGPhoto2::CameraWidget)

    macro inherited
      {% factory_id = @type.name.gsub(/^GPhoto2::/, "").gsub(/CameraWidget$/, "").underscore %}
      CameraWidget.widgets[{{factory_id.stringify}}] = self

      class ::GPhoto2::CameraWidget
        def as_{{factory_id}}
          self as {{@type.name}}
        end
      end
    end

    @parent : self?
    getter :parent

    @@widgets = {} of String => self.class

    def self.widgets
      @@widgets
    end

    def self.factory(ptr : FFI::LibGPhoto2::CameraWidget*, parent = nil) : self
      type = ptr.value.type.to_s.downcase
      klass = @@widgets[type]
      klass.new(ptr, parent)
    end

    def initialize(ptr : FFI::LibGPhoto2::CameraWidget*, @parent : self? = nil)
      super ptr
    end

    def finalize : Void
      free
    end

    def close : Void
      finalize
    end

    def type : FFI::LibGPhoto2::CameraWidgetType
      get_type
    end

    def label : String?
      get_label
    end

    def name : String?
      get_name
    end

    # @return [Object]
    def value
      get_value
    end

    # @return [Object]
    def value=(value)
      set_value(value)
      value
    end

    def children : Array(self)
      children = [] of self
      count_children.times.each { |i| children << get_child(i) }
      children
    end

    def flatten(map = {} of String => self)
      case type
      when .window?, .section?
        children.each &.flatten(map)
      else
        map[name.not_nil!] = self
      end
      map
    end

    def to_s(io)
      io << value
    end

    protected abstract def get_value
    protected abstract def set_value(value)

    private def free
      GPhoto2.check! FFI::LibGPhoto2.gp_widget_free(self)
    end

    private def get_type
      GPhoto2.check! FFI::LibGPhoto2.gp_widget_get_type(self, out type)
      type
    end

    private def get_label
      GPhoto2.check! FFI::LibGPhoto2.gp_widget_get_label(self, out ptr)
      !ptr ? nil : String.new ptr
    end

    private def get_name
      GPhoto2.check! FFI::LibGPhoto2.gp_widget_get_name(self, out ptr)
      !ptr ? nil : String.new ptr
    end

    private def count_children : Int32
      GPhoto2.check! FFI::LibGPhoto2.gp_widget_count_children(self)
    end

    private def get_child(index) : self
      GPhoto2.check! FFI::LibGPhoto2.gp_widget_get_child(self, index, out widget)
      CameraWidget.factory(widget, self)
    end
  end
end
