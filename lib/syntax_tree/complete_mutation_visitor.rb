# frozen_string_literal: true

module SyntaxTree
  # This is a fix for SyntaxTree::MutationVisitor not traversing the entire tree
  class CompleteMutationVisitor < SyntaxTree::BasicVisitor
    def initialize
      super
      @mutations = []
    end

    def mutate(query, &block)
      @mutations << [Pattern.new(query).compile, block]
    end

    def visit(node)
      return unless node

      result = node.accept(self)
      @mutations.each do |(pattern, mutation)|
        result = mutation.call(result) if pattern.call(result)
      end

      result
    end

    def copy_and_visit_children(node)
      node.dup.tap do |clone|
        clone.instance_variables.each do |name|
          next if %i[@location @comments].include?(name)

          var = clone.instance_variable_get(name)
          clone.instance_variable_set(name, visit_child(var))
        end
      end
    end

    def visit_child(child)
      case child
      when Array
        child.map { |node| visit_child(node) }
      when SyntaxTree::Node
        visit(child)
      else
        child
      end
    end

    alias visit_aref copy_and_visit_children
    alias visit_aref_field copy_and_visit_children
    alias visit_alias copy_and_visit_children
    alias visit_arg_block copy_and_visit_children
    alias visit_arg_paren copy_and_visit_children
    alias visit_arg_star copy_and_visit_children
    alias visit_args copy_and_visit_children
    alias visit_args_forward copy_and_visit_children
    alias visit_array copy_and_visit_children
    alias visit_aryptn copy_and_visit_children
    alias visit_assign copy_and_visit_children
    alias visit_assoc copy_and_visit_children
    alias visit_assoc_splat copy_and_visit_children
    alias visit_backref copy_and_visit_children
    alias visit_backtick copy_and_visit_children
    alias visit_bare_assoc_hash copy_and_visit_children
    alias visit_BEGIN copy_and_visit_children
    alias visit_begin copy_and_visit_children
    alias visit_binary copy_and_visit_children
    alias visit_block copy_and_visit_children
    alias visit_blockarg copy_and_visit_children
    alias visit_block_var copy_and_visit_children
    alias visit_bodystmt copy_and_visit_children
    alias visit_break copy_and_visit_children
    alias visit_call copy_and_visit_children
    alias visit_case copy_and_visit_children
    alias visit_CHAR copy_and_visit_children
    alias visit_class copy_and_visit_children
    alias visit_comma copy_and_visit_children
    alias visit_command copy_and_visit_children
    alias visit_command_call copy_and_visit_children
    alias visit_comment copy_and_visit_children
    alias visit_const copy_and_visit_children
    alias visit_const_path_field copy_and_visit_children
    alias visit_const_path_ref copy_and_visit_children
    alias visit_const_ref copy_and_visit_children
    alias visit_cvar copy_and_visit_children
    alias visit_def copy_and_visit_children
    alias visit_defined copy_and_visit_children
    alias visit_dyna_symbol copy_and_visit_children
    alias visit_END copy_and_visit_children
    alias visit_else copy_and_visit_children
    alias visit_elsif copy_and_visit_children
    alias visit_embdoc copy_and_visit_children
    alias visit_embexpr_beg copy_and_visit_children
    alias visit_embexpr_end copy_and_visit_children
    alias visit_embvar copy_and_visit_children
    alias visit_ensure copy_and_visit_children
    alias visit_excessed_comma copy_and_visit_children
    alias visit_field copy_and_visit_children
    alias visit_float copy_and_visit_children
    alias visit_fndptn copy_and_visit_children
    alias visit_for copy_and_visit_children
    alias visit_gvar copy_and_visit_children
    alias visit_hash copy_and_visit_children
    alias visit_heredoc copy_and_visit_children
    alias visit_heredoc_beg copy_and_visit_children
    alias visit_heredoc_end copy_and_visit_children
    alias visit_hshptn copy_and_visit_children
    alias visit_ident copy_and_visit_children
    alias visit_if copy_and_visit_children
    alias visit_if_op copy_and_visit_children
    alias visit_imaginary copy_and_visit_children
    alias visit_in copy_and_visit_children
    alias visit_int copy_and_visit_children
    alias visit_ivar copy_and_visit_children
    alias visit_kw copy_and_visit_children
    alias visit_kwrest_param copy_and_visit_children
    alias visit_label copy_and_visit_children
    alias visit_label_end copy_and_visit_children
    alias visit_lambda copy_and_visit_children
    alias visit_lambda_var copy_and_visit_children
    alias visit_lbrace copy_and_visit_children
    alias visit_lbracket copy_and_visit_children
    alias visit_lparen copy_and_visit_children
    alias visit_massign copy_and_visit_children
    alias visit_method_add_block copy_and_visit_children
    alias visit_mlhs copy_and_visit_children
    alias visit_mlhs_paren copy_and_visit_children
    alias visit_module copy_and_visit_children
    alias visit_mrhs copy_and_visit_children
    alias visit_next copy_and_visit_children
    alias visit_not copy_and_visit_children
    alias visit_op copy_and_visit_children
    alias visit_opassign copy_and_visit_children
    alias visit_params copy_and_visit_children
    alias visit_paren copy_and_visit_children
    alias visit_period copy_and_visit_children
    alias visit_pinned_begin copy_and_visit_children
    alias visit_pinned_var_ref copy_and_visit_children
    alias visit_program copy_and_visit_children
    alias visit_qsymbols copy_and_visit_children
    alias visit_qsymbols_beg copy_and_visit_children
    alias visit_qwords copy_and_visit_children
    alias visit_qwords_beg copy_and_visit_children
    alias visit_range copy_and_visit_children
    alias visit_rassign copy_and_visit_children
    alias visit_rational copy_and_visit_children
    alias visit_rbrace copy_and_visit_children
    alias visit_rbracket copy_and_visit_children
    alias visit_redo copy_and_visit_children
    alias visit_regexp_beg copy_and_visit_children
    alias visit_regexp_content copy_and_visit_children
    alias visit_regexp_end copy_and_visit_children
    alias visit_regexp_literal copy_and_visit_children
    alias visit_rescue copy_and_visit_children
    alias visit_rescue_ex copy_and_visit_children
    alias visit_rescue_mod copy_and_visit_children
    alias visit_rest_param copy_and_visit_children
    alias visit_retry copy_and_visit_children
    alias visit_return copy_and_visit_children
    alias visit_rparen copy_and_visit_children
    alias visit_sclass copy_and_visit_children
    alias visit_statements copy_and_visit_children
    alias visit_string_concat copy_and_visit_children
    alias visit_string_content copy_and_visit_children
    alias visit_string_dvar copy_and_visit_children
    alias visit_string_embexpr copy_and_visit_children
    alias visit_string_literal copy_and_visit_children
    alias visit_super copy_and_visit_children
    alias visit_symbeg copy_and_visit_children
    alias visit_symbol_content copy_and_visit_children
    alias visit_symbol_literal copy_and_visit_children
    alias visit_symbols copy_and_visit_children
    alias visit_symbols_beg copy_and_visit_children
    alias visit_tlambda copy_and_visit_children
    alias visit_tlambeg copy_and_visit_children
    alias visit_top_const_field copy_and_visit_children
    alias visit_top_const_ref copy_and_visit_children
    alias visit_tstring_beg copy_and_visit_children
    alias visit_tstring_content copy_and_visit_children
    alias visit_tstring_end copy_and_visit_children
    alias visit_unary copy_and_visit_children
    alias visit_undef copy_and_visit_children
    alias visit_unless copy_and_visit_children
    alias visit_until copy_and_visit_children
    alias visit_var_field copy_and_visit_children
    alias visit_var_ref copy_and_visit_children
    alias visit_vcall copy_and_visit_children
    alias visit_void_stmt copy_and_visit_children
    alias visit_when copy_and_visit_children
    alias visit_while copy_and_visit_children
    alias visit_word copy_and_visit_children
    alias visit_words copy_and_visit_children
    alias visit_words_beg copy_and_visit_children
    alias visit_xstring copy_and_visit_children
    alias visit_xstring_literal copy_and_visit_children
    alias visit_yield copy_and_visit_children
    alias visit_zsuper copy_and_visit_children
    alias visit___end__ copy_and_visit_children
  end
end
