module MemoryRecord
  module Association

    class Base

      attr_reader :name, :foreign_class_name, :klass, :foreign_klass, :name_writer

      def initialize klass, name, class_name
        @klass = klass
        @name = name
        @foreign_class_name = class_name

        @name_writer = "#{@name}="
      end

      def foreign_klass
        @foreign_klass ||= foreign_class_name.constantize
      end

    end

  end
end