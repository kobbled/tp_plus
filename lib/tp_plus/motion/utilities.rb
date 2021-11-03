module TPPlus
    module Motion
        module Utilities
            extend self
            def is_digit_or_letter?(char, expected)
                if char.to_s.match?(/[FUTfutNBDnbd]/)
                    return expected == :char
                elsif char.to_s.match?(/[-?\d+]/)
                    return expected == :number
                else
                    return false
                end
            end

            def merge_components(comp_list1, comp_list2, add_or_mask = false)
              # if set pose components are not the same size as the default components
              # merge the absent components with default components
              # set add_or_mask? to either add together comp_list1 and comp_list2
              # or mask comp_list1 and comp_list2
              if comp_list1.length < comp_list2.length
                a = comp_list1
                if add_or_mask
                  a = [comp_list1, comp_list2[0..comp_list1.length-1]].transpose.map {|x| x.reduce(:+)}
                end

                comp_list_merge = (a << comp_list2[comp_list1.length..-1]).flatten
              else
                if add_or_mask
                  comp_list_merge = [comp_list1, comp_list2].transpose.map {|x| x.reduce(:+)}
                else
                  comp_list_merge = comp_list1.clone
                end
              end

              comp_list_merge
            end

            def merge_components_back(comp_list1, comp_list2, add_or_mask = false)
              # if set pose components are not the same size as the default components
              # merge the absent components with default components
              # set add_or_mask? to either add together comp_list1 and comp_list2
              # or mask comp_list1 and comp_list2
              if comp_list1.length < comp_list2.length
                a = comp_list1
                if add_or_mask
                  a = [comp_list1, comp_list2[comp_list1.length..-1]].transpose.map {|x| x.reduce(:+)}
                end

                comp_list_merge = (comp_list2[0..comp_list1.length-1] << a).flatten
              else
                if add_or_mask
                  comp_list_merge = [comp_list1, comp_list2].transpose.map {|x| x.reduce(:+)}
                else
                  comp_list_merge = comp_list1.clone
                end
              end

              comp_list_merge
            end
            end
        end
    end
end