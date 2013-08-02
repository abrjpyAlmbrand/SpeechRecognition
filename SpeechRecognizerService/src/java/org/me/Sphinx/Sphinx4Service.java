package org.me.Sphinx;

import javax.jws.WebService;
import javax.jws.WebMethod;
import javax.jws.WebParam;

import edu.cmu.sphinx.frontend.util.AudioFileDataSource;
import edu.cmu.sphinx.recognizer.Recognizer;
import edu.cmu.sphinx.result.Result;
import edu.cmu.sphinx.util.props.ConfigurationManager;

import java.io.File;
import javax.sound.sampled.UnsupportedAudioFileException;
import java.io.IOException;
import java.net.URL;
import java.io.FileOutputStream;

@WebService(serviceName = "Sphinx4Service")
public class Sphinx4Service {
    
    /**-----------------------------------------------------------------------
     * Get string type text from Audio file (Audio file transmit through parameters)
     -----------------------------------------------------------------------*/
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
    
    public class Transcriber {
        
        public String Recognise(File AudioFile) throws IOException, UnsupportedAudioFileException {
            URL configURL = org.me.Sphinx.Sphinx4Service.class.getResource("config.xml");
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
    
    private File frombytes(byte[] bytesarray)       
    {
        File someFile = new File("AudioFile");
        try
        {
            FileOutputStream fos = new FileOutputStream(someFile);
            fos.write(bytesarray);  
        }
        catch(Exception e)
        {
        }        
        return someFile;
    }
}