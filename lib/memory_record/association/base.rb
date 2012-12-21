module MemoryRecord
  module Association

    class Base

      attr_reader :name, :name_writer, :foreign_class_name, :klass, :foreign_klass

      def initialize klass, name, class_name
        @klass = klass
        @name = name
        @foreign_class_name = class_name

        @name_writer = "#{@name}="
      end

      # foreign_klass can be nil during a polymorphic has_many association
      def foreign_klass
        @foreign_klass ||= foreign_class_name.constantize if foreign_class_name
      end

    end

  end
end