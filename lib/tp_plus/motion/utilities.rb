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

            def merge_components(comp_list1, comp_list2)
                #if set pose components are not the same size as the default components
                #merge the absent components with default components
                comp_list_merge = comp_list1.clone
                if comp_list1.length < comp_list2.length
                    comp_list_merge = (comp_list1 << comp_list2[comp_list1.length..-1]).flatten
                end

                comp_list_merge
            end

            def merge_components_back(comp_list1, comp_list2)
                #if set pose components are not the same size as the default components
                #merge the absent components with default components
                comp_list_merge = comp_list1.clone
                if comp_list1.length < comp_list2.length
                    comp_list_merge = (comp_list2[0..comp_list1.length-1] << comp_list1).flatten
                end

                comp_list_merge
            end
        end
    end
end