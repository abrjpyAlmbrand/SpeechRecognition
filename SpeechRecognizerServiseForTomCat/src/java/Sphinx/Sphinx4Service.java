package Sphinx;

import javax.jws.WebService;
import javax.jws.WebMethod;
import javax.jws.WebParam;

import edu.cmu.sphinx.frontend.util.AudioFileDataSource;
import edu.cmu.sphinx.recognizer.Recognizer;
import edu.cmu.sphinx.result.Result;
import edu.cmu.sphinx.util.props.ConfigurationManager;
import java.io.BufferedReader;
import java.io.DataOutputStream;

import java.io.File;
import javax.sound.sampled.UnsupportedAudioFileException;
import java.io.IOException;
import java.net.URL;
import java.io.FileOutputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;
import net.sourceforge.javajson.JsonArray;
import net.sourceforge.javajson.JsonObject;
import org.apache.log4j.Logger;

@WebService(serviceName = "Sphinx4Service")
public class Sphinx4Service {
    //initializing the logger
    static Logger log = Logger.getLogger(Sphinx4Service.class.getName());
    /**----------------------------------------------------------------------
     * Returns string type text from byte array
     ----------------------------------------------------------------------*/
    @WebMethod(operationName = "GetStringFromAudio")
    public String GetStringFromAudio(@WebParam(name = "ByteStream") byte[] ByteStream) {
        String Text;
        Sphinx4Service.Transcriber newMethod = new Sphinx4Service.Transcriber();
        if (ByteStream!=null)
        {
            File AudioFile = frombytes(ByteStream);
            try
            {
                Text = newMethod.Recognise(AudioFile);
            }
            catch(Exception e)
            {
                //Text=e.toString();
                Text = "Unknown command, please try again.";
                log.error("This is an Error: " + e.toString());
                log.error("Sphinx response: " + Text);
                
            }       
            return Text;
        }
        else
            log.info("Byte array is empty, you need to send ByteStream in order to get result");
            return "null";    
    }          
    /**------------------------------------------------------------------------
     * Sphinx4 logic
     ------------------------------------------------------------------------*/    
    public class Transcriber {
        
        public String Recognise(File AudioFile) throws IOException, UnsupportedAudioFileException {
            URL configURL = Sphinx.Sphinx4Service.class.getResource("config.xml");
            ConfigurationManager cm = new ConfigurationManager(configURL);
            Recognizer recognizer = (Recognizer) cm.lookup("recognizer");
            /* allocate the resource necessary for the recognizer */
            recognizer.allocate();
            // configure the audio input for the recognizer
            AudioFileDataSource dataSource = (AudioFileDataSource) cm.lookup("audioFileDataSource");
            dataSource.setAudioFile(AudioFile, null);
            // Loop until last utterance in the audio file has been decoded, in which case the recognizer will return null.
            Result result;
            String stringline = "";
            while ((result = recognizer.recognize())!= null) {
                    stringline = stringline + result.getBestResultNoFiller() + ' ';
            }
            log.info("Sphinx response: " + stringline);
            return stringline;
        }
    }
    /**------------------------------------------------------------------------
     * Converts byte array to audio file
     ------------------------------------------------------------------------*/    
    private File frombytes(byte[] bytesarray)       
    {
        File AudioFile = new File("AudioFile");
        try
        {
            FileOutputStream fos = new FileOutputStream(AudioFile);
            fos.write(bytesarray);  
        }
        catch(Exception e)
        {
            log.error("Error converting byte array to file: " + e.toString());
        }        
        return AudioFile;
    }
/*
 * 
 * Google Speech api
 */
@WebMethod(operationName = "GetStringFromGoogle")
    public String GetStringFromGoogle(@WebParam(name = "ByteStream") byte[] ByteStream) {
      try {
    String request = "https://www.google.com/"+"speech-api/v1/recognize?"+ 
                        "xjerr=1&client=speech2text&lang=en-US&maxresults=10";
            
      URL url = new URL(request); 
      HttpURLConnection connection = (HttpURLConnection) url.openConnection();           
      connection.setDoOutput(true);
      connection.setDoInput(true);
      connection.setInstanceFollowRedirects(false); 
      connection.setRequestMethod("POST"); 
      connection.setRequestProperty("Content-Type", "audio/x-flac; rate=44000"); 
      connection.setRequestProperty("User-Agent", "speech2text"); 
      connection.setConnectTimeout(60000);
      connection.setUseCaches (false);
       DataOutputStream wr = new DataOutputStream(connection.getOutputStream ());
       wr.write(ByteStream);
       wr.flush();
       wr.close();
       connection.disconnect();
       BufferedReader in = new BufferedReader( new InputStreamReader(connection.getInputStream()));
       String decodedString;  
       String answerFromGoogle = "";
       while ((decodedString = in.readLine()) != null) {
		answerFromGoogle += decodedString;
       }
       String response = ResponseCommandText(ParsingJsonArray(answerFromGoogle));
       log.info("Google response: "  + response);
       
       
       return response; 
      }
      catch (Exception ee)
      {
          return ee.toString();
      }                      
    }
    
    /*
     * Parse json response array elements into list
     * request - json response from Google API
     */
    private List<String> ParsingJsonArray(String request)
    {   
        
        ArrayList<String> jsonElementArray = new ArrayList<String>();
        try {
            log.info("JSON: " + request);
            JsonObject json = JsonObject.parse(request);
            JsonArray hyphypothesesArray = json.getJsonArray("hypotheses");
            for (int i=0; i <hyphypothesesArray.size(); i++)
             {
                JsonObject jsonArrayElement = hyphypothesesArray.getJsonObject(i);
                String plainElement = jsonArrayElement.getString("utterance");
                jsonElementArray.add(plainElement);           
             }
            
        }
        catch (Exception ex)
        {
            log.error("This is an Error: " + ex.toString());
            
        }
        return jsonElementArray;
    }
    
    /*
     *  messageToCheck - element from responded values list
     */
    private static boolean IsAnswerValid(String messageToCheck)
    {
      boolean isValid = false;
      String [] commands = {"open", "close", "play", "pause", "stop", "resume", "hide" };
      for (String item : commands) {
            if (messageToCheck.equalsIgnoreCase(item)) {
            isValid = true;
            break; 
         }     
    }     
      return isValid;  
    }
    
    
    /*
     * listOfvalues - list of responded values from ParsingJsonArray method
     */
    private String ResponseCommandText(List<String> listOfvalues)
    {
       String message = "Unknown command, please try again.";
       int index = 0;
       for (String item : listOfvalues)
       {
       if(IsAnswerValid(listOfvalues.get(index)) == true)
               {                 
                   message = listOfvalues.get(index);
                   break;
               }
       else
       {
                    message = "Unknown command, please try again.";
       }
            index++;
       }
       return message;
    }
}