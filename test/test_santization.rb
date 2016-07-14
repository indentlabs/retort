# encoding: utf-8

gem "minitest" # ensure that we're using the gem, and not a built-in
require "minitest/autorun"
require_relative '../services/sanitization_service'

describe SanitizationService do
  describe '#trim_whitespace' do
    it 'removes leading spaces' do
      SanitizationService
        .trim_whitespace(' message')
        .must_equal('message')
    end
    
    it 'removes trailing spaces' do
      SanitizationService
        .trim_whitespace('message ')
        .must_equal('message')
    end
    
    it 'removes trailing newlines' do
      SanitizationService
        .trim_whitespace("message\n")
        .must_equal('message')
    end
    
    it 'squeezes multiple spaces into one' do
      SanitizationService
        .trim_whitespace('some  spaces')
        .must_equal('some spaces')
    end
  end
  
  describe '#capitalize_properly' do
    it 'capitalizes the first letter of a word' do
      SanitizationService
        .capitalize_properly('message')
        .must_equal('Message')
    end
  end
  
  describe '#punctuate_properly' do
    it 'removes the last character if the sentence is not terminated' do
      SanitizationService
        .punctuate_properly('message.')
        .must_equal('message')
    end
  end
  
  describe '#remove_links' do
    it 'does not change messages that do not contain a link' do
      SanitizationService
        .remove_links('message')
        .must_equal('message')
    end
  end
  
  describe '#remove_biblical_chapters' do
    it 'removes initial caret and digit' do
      SanitizationService
        .remove_biblical_chapters('^5Text')
        .must_equal('Text')
    end
    
    it "doesn't remove any other caret" do
      SanitizationService
        .remove_biblical_chapters('5^Text')
        .must_equal('5^Text')
    end
    
    it "doesn't remove a leading digit" do
      SanitizationService
        .remove_biblical_chapters('5Text')
        .must_equal('5Text')
    end
  end
  
  describe '#swap_special_characters' do
    it 'swaps left UTF-8 smart-quotes for regular quotes' do
      SanitizationService
        .swap_special_characters('“')
        .must_equal('"')
    end
    
    it 'swaps right UTF-8 smart quotes for regular quotes' do
      SanitizationService
        .swap_special_characters('”')
        .must_equal('"')
    end
    
    it 'swaps right UTF-8 single quote for regular apostrophe' do
      SanitizationService
        .swap_special_characters('’')
        .must_equal('’')
    end
  end
  
  describe '#match_parentheses' do
    it 'does not modify messages with equal numbers of parentheses' do
      SanitizationService
        .match_parentheses('()')
        .must_equal('()')
    end
    
    it 'appends closing parentheses if there are not enough' do
      SanitizationService
        .match_parentheses('(')
        .must_equal('()')
    end
    
    it 'prepends opening parentheses if there are not enough' do
      SanitizationService
        .match_parentheses(')')
        .must_equal('()')
    end
  end
  
  describe '#match_quotes' do
    it 'does not modify messages with equal numbers of double-quotes' do
      SanitizationService
        .match_quotes('""')
        .must_equal('""')
    end
    
    it 'appends closing double-quotes if there are not enough' do
      SanitizationService
        .match_quotes('"word')
        .must_equal('"word"')
    end
    
    it 'prepends opening double-quotes if there are not enough' do
      SanitizationService
        .match_quotes('word"')
        .must_equal('"word"')
    end
    
    it 'does not modify messages with equal numbers of single-quotes' do
      SanitizationService
        .match_quotes("''")
        .must_equal("''")
    end
    
    it 'appends closing single-quotes if there are not enough' do
      SanitizationService
        .match_quotes("'word")
        .must_equal("'word'")
    end
    
    it 'prepends opening single-quotes if there are not enough' do
      SanitizationService
        .match_quotes("word'")
        .must_equal("'word'")
    end
  end
  
  describe '#remove_symbols' do
    it 'removes anything that is not alphanumeric or puncutation' do
      SanitizationService
        .remove_symbols('\\/*-+@#%^&*()')
        .must_equal('')
    end
  end
end
