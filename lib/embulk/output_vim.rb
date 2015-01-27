module Embulk
  class OutputVim < OutputPlugin
    Plugin.register_output('vim', self)

    def self.transaction(config, schema, processor_count, &control)
      commit_reports = yield({})
      return {}
    end

    def initialize(task, schema, index)
      @vim = `vim --serverlist`.lines.first.chomp or die "embulk-plugin-vim require gvim!"
      system('vim', '--servername', @vim, '--remote-send', ":sp embulk.out<cr>")
      super
      @records = 0
    end

    def close
    end

    def add(page)
      page.each do |record|
        system('vim', '--servername', @vim, '--remote-expr', "append('$', '#{record.join(",")}')")
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
