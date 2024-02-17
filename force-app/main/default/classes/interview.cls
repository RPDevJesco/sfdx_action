public class interview {
    /*
     * You are given a string 'str' of length 'N'.
     * Your task is to reverse the original string word by word.
     *
     * There can be multiple spaces between two words and there can be leading or trailing spaces,
     * but in the output reversed string you need to put a single space between two words.
     * Your reversed string should not contain leading or trailing spaces.
     *
     * Your answer should also handle empty input.

     * Input: 'word  kaleidoscope penguin'
     * Output: 'penguin kaleidoscope word'
     *
     * Input: '  word  kaleidoscope penguin    '
     * Output: 'penguin kaleidoscope word'
     *
     * Input: '      '
     * Output: ''
     *
     * Input: null
     * Output: ''
     */
    public static String question1(String value) {
        if (value == null || value.isWhitespace()) return '';
        // split the words into an array
        List<String> stringValues = new List<String>();
        String finalString = '';
        for (String result : value.split(' ')) {
            if (!result.isWhitespace()) {
                stringValues.add(result.trim());
            }
        }
        System.debug(stringValues);
        // assemble new string from array with the order being reverse (2,1,0)
        // return the new string value
        for (Integer i = stringValues.size() - 1; i >= 0; i--) {
            finalString += stringValues[i];
            if (i > 0) {
                finalString += ' '; // Add space between words
            }
        }
        return finalString;
    }
}