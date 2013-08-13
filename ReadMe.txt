Instuction how to add another commands for Speech recognition:

To add new commands for speech recognizer go to SpeechRecognizerService\src\java\org\me\Sphinx 
directory and open Commands.gram in text editor. 

Add new words in 9 line, separating words with 
| symbol, in example:
public <commands> = (open | play | pause | hide | stop | close | resume | newword) * ;

To check if such word exist in dictionary, go to SpeechRecognizerService\lib, extract WSJ_8gau_13dCep_16k_40mel_130Hz_6800Hz.jar, 
go to WSJ_8gau_13dCep_16k_40mel_130Hz_6800Hz\dict, open cmudict.0.6d in text editor and search for a word you want to add.

If such word does not exist or you wanna add different language dictionary follow this 
guide: http://www.youtube.com/watch?v=7YdE-VpVchw. 
To get different language models go here: http://sourceforge.net/projects/cmusphinx/files/Acoustic%20and%20Language%20Models/

You can find more information about sphinx voice recognition http://cmusphinx.sourceforge.net/

Existing commands:
Close, hide, open, pause, play, resume, stop.

Spelling:
CLOSE                K L OW S
CLOSE(2)             K L OW Z
HIDE                 HH AY D
OPEN                 OW P AH N
PAUSE                P AO Z
PLAY                 P L EY
RESUME               R EH Z AH M EY
RESUME(2)            R IH Z UW M
RESUME(3)            R IY Z UW M
STOP                 S T AA P
