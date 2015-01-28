module Embulk
  class OutputVim < OutputPlugin
    Plugin.register_output('vim', self)

    def self.transaction(config, schema, processor_count, &control)
      commit_reports = yield({})
      return {}
    end

    def initialize(task, schema, index)
      @vim = `vim --serverlist`.lines.first
      raise "embulk-plugin-vim require gvim!" unless @vim
      @vim.chomp!
      system('vim', '--servername', @vim, '--remote-send', ":silent sp embulk.csv<cr>:%d<cr>")
      system('vim', '--servername', @vim, '--remote-expr', "append('$', '#{schema.map{|x| x.name}.join(",").gsub(/(['\\])/, '\\\1')}') ? '' : 'OK'")
      super
      @records = 0
    end

    def close
    end

    def add(page)
      page.each do |record|
        system('vim', '--servername', @vim, '--remote-expr', "append('$', '#{record.join(",").gsub(/(['\\])/, '\\\1')}') ? '' : 'OK'")
        @records += 1 
      end
    end

    def finish
    end

    def abort
    end

    def commit
      system('vim', '--servername', @vim, '--remote-send', "ggdd<c-l>")
      return { "records" => @records }
    end
  end
end
