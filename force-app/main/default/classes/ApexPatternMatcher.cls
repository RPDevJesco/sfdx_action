public class ApexPatternMatcher {
    public static Pattern classPattern = Pattern.compile('(\\w+)?\\s*(public|private|protected|global)?\\s*(\\w+)?\\s*class\\s+(\\w+)');
    public static Pattern variablePattern = Pattern.compile('(\\w+)?\\s*(public|private|protected|global|static)?\\s*(\\w+)\\s+(\\w+);');
    public static Pattern methodSignaturePattern = Pattern.compile('(?:public|protected|private|global|static)?\\s+\\w+\\s+\\w+\\s*\\([^)]*\\)');
    public static Pattern methodPattern = Pattern.compile('(public|private|protected|global)\\s*(static)?\\s*(\\w+)\\s+(\\w+)\\s*\\([^)]*\\)');
    public static Pattern constructorPattern = Pattern.compile('(public|private|protected|global)?\\s*(\\w+)\\s*\\(([^)]*)\\)\\s*\\{([^}]*)\\}');
    public static Pattern singleCommentPattern = Pattern.compile('//(.*)');
    public static Pattern multiCommentPattern = Pattern.compile('/\\*([^*]|\\*(?!/))*\\*/');
    public static Pattern docCommentPattern = Pattern.compile('/\\*\\*([^*]|\\*(?!/))*\\*/');
    public static Pattern annotationPattern = Pattern.compile('@\\w+');

    public static void parseClassBody(String classBody) {
        List<String> lines = classBody.split('\n');
        for(String line: lines){
            line = line.trim();
            Matcher m;
            if(line.contains('class')){
                m = classPattern.matcher(line);
                if(m.find()){
                    System.debug('Class: ' + m.group(1));
                }
            } else if((line.startsWith('public') || line.startsWith('private') || line.startsWith('protected')) && line.contains('(')) {
                m = methodPattern.matcher(line);
                if(m.find()){
                    System.debug('Method: ' + m.group(2) + ' Return Type: ' + m.group(1));
                }
            } else if(line.startsWith('public') || line.startsWith('private') || line.startsWith('protected') || line.startsWith('static')) {
                m = variablePattern.matcher(line);
                if(m.find()){
                    System.debug('Variable: ' + m.group(2) + ' Type: ' + m.group(1));
                }
            } else if(line.startsWith('@')) {
                m = annotationPattern.matcher(line);
                while(m.find()){
                    System.debug('Annotation: ' + m.group(0));
                }
            }
        }
    }

    // Method to match and extract class-related information
    public static List<String> matchClass(String classBody) {
        List<String> matchedClasses = new List<String>();
        Matcher m = classPattern.matcher(classBody);
        while (m.find()) {
            System.debug('Matched Class: ' + m.group(0));
            matchedClasses.add(m.group(0)); // Modify to extract the needed groups
        }
        return matchedClasses;
    }

    // Method to match and extract variable-related information
    public static List<String> matchVariable(String classBody) {
        List<String> matchedVariables = new List<String>();
        List<String> lines = classBody.split('\n');
        for(String line: lines){
            line = line.trim();
            if((line.startsWith('public') || line.startsWith('private') || line.startsWith('protected') || line.startsWith('static')) && line.endsWith(';')) {
                Matcher m = variablePattern.matcher(line);
                while (m.find()) {
                    System.debug('Matched Variable: ' + m.group(0));
                    matchedVariables.add(m.group(0)); // Modify to extract the needed groups
                }
            }
        }
        return matchedVariables;
    }

    // Method to match and extract method-related information
    public static List<String> matchMethodWithFullFunctionBody(String classBody) {
        List<String> matchedMethods = new List<String>();
        List<String> lines = classBody.split('\n');
        String currentBlock = '';
        Boolean isWithinMethod = false;

        for(String line: lines) {
            line = line.trim();
            // Checking the line whether it could be a starting of a method by observing '('
            if((line.startsWith('public') || line.startsWith('private') || line.startsWith('protected') || line.startsWith('global')) && line.contains('(')) {
                isWithinMethod = true;
            }

            if(isWithinMethod) {
                currentBlock += line + ' '; // Appending the current line to the block
            }

            // When we find the closing brace '}', we will perform the match
            if(isWithinMethod && line.contains('}')) {
                Matcher m = methodPattern.matcher(currentBlock);
                if(m.find()) {
                    System.debug('Matched Method: ' + m.group(0));
                    matchedMethods.add(m.group(0)); // Modify to extract the needed groups
                }
                // Resetting the flags and the block string for the next method
                isWithinMethod = false;
                currentBlock = '';
            }
        }

        return matchedMethods;
    }

    // Method to match and extract method-related information
    public static List<String> matchMethod(String classBody) {
        List<String> matchedMethods = new List<String>();
        List<String> lines = classBody.split('\n');
        String currentBlock = '';
        Boolean isWithinMethod = false;
        Integer braceCount = 0;

        for(String line: lines) {
            line = line.trim();
            if((line.startsWith('public') || line.startsWith('private') || line.startsWith('protected') || line.startsWith('global')) && line.contains('(')) {
                isWithinMethod = true;
            }

            if(isWithinMethod) {
                currentBlock += line + ' ';
                braceCount += line.countMatches('{') - line.countMatches('}');

                if(braceCount == 0) {
                    Matcher m = methodSignaturePattern.matcher(currentBlock);
                    if(m.find()) {
                        System.debug('Matched Method: ' + m.group(0));
                        matchedMethods.add(m.group(0)); // Modify to extract the needed groups
                    }
                    // Resetting the flags and the block string for the next method
                    isWithinMethod = false;
                    currentBlock = '';
                }
            }
        }
        return matchedMethods;
    }

    // Method to match and extract constructor-related information
    public static List<String> matchConstructor(String classBody) {
        List<String> matchedConstructors = new List<String>();
        Matcher m = constructorPattern.matcher(classBody);
        while (m.find()) {
            System.debug('Matched Constructor: ' + m.group(0));
            matchedConstructors.add(m.group(0)); // Modify to extract the needed groups
        }
        return matchedConstructors;
    }

    // Method to match and extract single line comment related information
    public static List<String> matchSingleComment(String classBody) {
        List<String> matchedSingleCommentPatterns = new List<String>();
        Matcher m = singleCommentPattern.matcher(classBody);
        while (m.find()) {
            System.debug('Matched Single Comment: ' + m.group(0));
            matchedSingleCommentPatterns.add(m.group(0)); // Modify to extract the needed groups
        }
        return matchedSingleCommentPatterns;
    }

    // Method to match and extract multi line comment related information
    public static List<String> matchMultiComment(String classBody) {
        List<String> matchedMultiComments = new List<String>();
        Matcher m = multiCommentPattern.matcher(classBody);
        while (m.find()) {
            System.debug('Matched Multi-Comments: ' + m.group(0));
            matchedMultiComments.add(m.group(0)); // Modify to extract the needed groups
        }
        return matchedMultiComments;
    }

    // Method to match and extract doc style comment related information
    public static List<String> matchDocComment(String classBody) {
        List<String> matchedDocComments = new List<String>();
        Matcher m = docCommentPattern.matcher(classBody);
        while (m.find()) {
            System.debug('Matched DocComment: ' + m.group(0));
            matchedDocComments.add(m.group(0)); // Modify to extract the needed groups
        }
        return matchedDocComments;
    }

    // Method to match and extract annotation-related information
    public static List<String> matchAnnotation(String classBody) {
        List<String> matchedAnnotations = new List<String>();
        Matcher m = annotationPattern.matcher(classBody);
        while (m.find()) {
            System.debug('Matched Annotation: ' + m.group(0));
            matchedAnnotations.add(m.group(0)); // Modify to extract the needed groups
        }
        return matchedAnnotations;
    }
}