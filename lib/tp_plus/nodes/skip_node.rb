module TPPlus
  module Nodes
    class SkipNode < BaseNode
      def initialize(target, lpos_pr)
        @target = target
        @lpos_pr = lpos_pr
      end

      def lpos_pr(context)
        return "" if @lpos_pr.nil?

        ",#{@lpos_pr.eval(context)}=LPOS"
      end

      def eval(context)
        raise "Label (#{@target}) not found" if context.labels[@target.to_sym].nil?

        "Skip,LBL[#{context.labels[@target.to_sym]}]#{lpos_pr(context)}"
      end
    end
  end
end
