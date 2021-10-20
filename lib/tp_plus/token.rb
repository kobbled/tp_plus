module TPPlus
  class Token
    KEYWORDS = {
        "abort" => :ABORT,
        "acc" => :ACC,
        "after" => :AFTER,
        "at" => :AT,
        "arc_move" => :MOVE,
        "case" => :CASE,

        "coord" => :COORD,
        "pth" => :PTH,
        "increment" => :INC,
        "minimal_rotation" => :MROT,
        "mrot" => :MROT,
        "wrist_joint" => :WJNT,
        "wjnt" => :WJNT,
        "rtcp" => :RTCP,
        "break" => :BREAK,
        "fplin" => :FPLIN,
        "faceplate_linear" => :FPLIN,

        "approach_ld" => :AP_LD,
        "ap_ld" => :AP_LD,
        "retract_ld" => :RT_LD,
        "rt_ld" => :RT_LD,
        "corner_distance" => :CD,
        "cd" => :CD,
        "corner_region" => :CR,
        "cr" => :CR,
        "independent_ev" => :INDEV,
        "indev" => :INDEV,
        "simultaneous_ev" => :EV,
        "ev" => :EV,
        "process_speed" => :PSPD,
        "pspd" => :PSPD,
        "continuous_rotation_speed" => :CTV,
        "ctv" => :CTV,

        "circular_move" => :MOVE,
        "elsif" => :ELSIF,
        "else" => :ELSE,
        "end" => :END,
        "eval" => :EVAL,
        "for" => :FOR,
        "mid" => :MID,
        "get_joint_position" => :JPOS,
        "get_linear_position" => :LPOS,
        "group" => :GROUP,
        "if" => :IF,
        "indirect" => :INDIRECT,
        "then" => :THEN,
        "in" => :IN,
        "joint_move" => :MOVE,
        "jump_to" => :JUMP,
        "linear_move" => :MOVE,
        "message" => :MESSAGE,
        "namespace" => :NAMESPACE,
        "offset" => :OFFSET,
        "pause" => :PAUSE,
        "position_data" => :POSITION_DATA,
        "pulse" => :IO_METHOD,
        "raise" => :RAISE,
        "reset" => :TIMER_METHOD,
        "restart" => :TIMER_METHOD,
        "return" => :RETURN,
        "run" => :RUN,
        "call" => :CALL,
        "skip_to" => :SKIP,
        "start" => :TIMER_METHOD,
        "stop" => :TIMER_METHOD,
        "term" => :TERM,
        "time_after" => :TIME_SEGMENT,
        "time_before" => :TIME_SEGMENT,
        "timeout_to" => :TIMEOUT,
        "toggle" => :IO_METHOD,
        "tool_offset" => :OFFSET,
        "turn_on" => :IO_METHOD,
        "turn_off" => :IO_METHOD,
        "to" => :TO,
        "downto" => :DOWNTO,
        "unless" => :UNLESS,
        "vision_offset" => :OFFSET,
        "warning" => :WARNING,
        "wait_for" => :WAIT_FOR,
        "wait_until" => :WAIT_UNTIL,
        "when" => :WHEN,
        "while" => :WHILE,

        "DIV" => :DIV,
        "system" => :SYSTEM,

        "true" => :TRUE_FALSE,
        "false" => :TRUE_FALSE,

        "TP_IGNORE_PAUSE" => :TP_HEADER,
        "TP_COMMENT" => :TP_HEADER,
        "TP_GROUPMASK" => :TP_HEADER,
        "TP_SUBTYPE" => :TP_HEADER,

        "PAINT_PROCESS" => :TP_APPLICATION_TYPE,
        "AUTO_SINGULARITY_HEADER" => :TP_APPLICATION_TYPE,
        "LINE_TRACK" => :TP_APPLICATION_TYPE,

        "set_skip_condition" => :SET_SKIP_CONDITION,
        "use_payload" => :FANUC_USE,
        "use_uframe" => :FANUC_USE,
        "use_utool" => :FANUC_USE,		
        "use_override" => :FANUC_USE,

        "colguard_on" => :COLL_GUARD,
        "adjust_colguard" => :COLL_GUARD,
        "colguard_off" => :COLL_GUARD,

        "def" => :FUNCTION,
        "using" => :USING
      }


    DATA = {
        "R" => :NUMREG,
        "P" => :POSITION,
        "PR" => :POSREG,
        "VR" => :VREG,
        "SR" => :SREG,
        "AR" => :ARG,
        "TIMER" => :TIMER,
        "UALM" => :UALM,
        "UTOOL" => :TOOLREG,
        "UFRAME" => :FRAMEREG,


        "SIN" => :OPERATION,
        "COS" => :OPERATION,
        "TAN" => :OPERATION,
        "ASIN" => :OPERATION,
        "ACOS" => :OPERATION,
        "ATAN" => :OPERATION,
        "ATAN2" => :OPERATION,
        "SQRT" => :OPERATION,
        "LN" => :OPERATION,
        "EXP" => :OPERATION,
        "ABS" => :OPERATION,
        "TRUNC" => :OPERATION,
        "ROUND" => :OPERATION,

        "F" => :OUTPUT,
        "AO" => :OUTPUT,
        "DO" => :OUTPUT,
        "RO" => :OUTPUT,
        "UO" => :OUTPUT,
        "SO" => :OUTPUT,
        "GO" => :OUTPUT,

        "AI" => :INPUT,
        "DI" => :INPUT,
        "RI" => :INPUT,
        "UI" => :INPUT,
        "SI" => :INPUT,
        "GI" => :INPUT
      }

    def self.lookup(string)
      KEYWORDS[string] || :WORD
    end

    def self.lookup_data(string)
      DATA[string] || :WORD
    end
  end
end
