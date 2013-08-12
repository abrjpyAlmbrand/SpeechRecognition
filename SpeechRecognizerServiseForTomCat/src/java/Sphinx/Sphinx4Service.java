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
import java.net.ProtocolException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebService(serviceName = "Sphinx4Service")
public class Sphinx4Service {

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
                Text=e.toString();
            }       
            return Text;
        }
        else
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
      connection.setRequestProperty("Content-Type", "audio/x-flac; rate=16000"); 
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
       String aaa = "";
       while ((decodedString = in.readLine()) != null) {
		aaa += decodedString;
       }
       return aaa;
          
      }
      catch (Exception ee){
          return ee.toString();
      }
                      

}


}
