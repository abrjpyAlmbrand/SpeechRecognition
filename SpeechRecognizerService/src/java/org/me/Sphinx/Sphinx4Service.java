/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.me.Sphinx;

import javax.jws.WebService;
import javax.jws.WebMethod;
import javax.jws.WebParam;


import edu.cmu.sphinx.frontend.util.AudioFileDataSource;
import edu.cmu.sphinx.recognizer.Recognizer;
import edu.cmu.sphinx.result.Result;
import edu.cmu.sphinx.util.props.ConfigurationManager;
import java.io.ByteArrayOutputStream;
import java.io.File;

import javax.sound.sampled.UnsupportedAudioFileException;
import java.io.IOException;
import java.net.URL;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.util.logging.Level;
import java.util.logging.Logger;
/**
 *
 * @author Studentas
 */
@WebService(serviceName = "Sphinx4Service")
public class Sphinx4Service {

    /**-----------------------------------------------------------------------
     * Get string type text from Audio file (Audio file must be already saved)
     -----------------------------------------------------------------------*/
    @WebMethod(operationName = "GetStringFromAudio")
    public String GetStringFromAudio() {
        String Text;
        Sphinx4Service.Transcriber newMethod = new Sphinx4Service.Transcriber();
        try
        {
            Text = newMethod.Recognise();
        }
        catch(Exception e)
        {
            return null;
        }
        return Text;
    }
    
    public class Transcriber {
        
        public String Recognise() throws IOException, UnsupportedAudioFileException {
            URL audioURL;
            audioURL = edu.cmu.sphinx.demo.transcriber.Transcriber.class.getResource("AudioFile.wav");
            URL configURL = edu.cmu.sphinx.demo.transcriber.Transcriber.class.getResource("config.xml");
            ConfigurationManager cm = new ConfigurationManager(configURL);
            Recognizer recognizer = (Recognizer) cm.lookup("recognizer");
            /* allocate the resource necessary for the recognizer */
            recognizer.allocate();
            // configure the audio input for the recognizer
            AudioFileDataSource dataSource = (AudioFileDataSource) cm.lookup("audioFileDataSource");
            dataSource.setAudioFile(audioURL, null);
            // Loop until last utterance in the audio file has been decoded, in which case the recognizer will return null.
            Result result;
            String stringline = "";
            while ((result = recognizer.recognize())!= null) {
                    stringline = stringline + ' ' + result.getBestResultNoFiller();
                    System.out.println(stringline);
            }
            return stringline;
        }
    }

    /**-----------------------------------------------------------------------
     * Get string type text from Audio file (Audio file transmit through parameters)
     -----------------------------------------------------------------------*/
    @WebMethod(operationName = "GetStringFromAudio2")
    public String GetStringFromAudio2(@WebParam(name = "AudioFile") byte[] AudioFile) {
       String Text;
        Sphinx4Service.Transcriber2 newMethod = new Sphinx4Service.Transcriber2();
        if (AudioFile!=null)
        {
            File filas = frombytes(AudioFile) ;
               try
        {
            Text = newMethod.Recognise(filas);
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
    
    public class Transcriber2 {
        
        public String Recognise(File AudioFile) throws IOException, UnsupportedAudioFileException {
            URL audioURL;
            audioURL = edu.cmu.sphinx.demo.transcriber.Transcriber.class.getResource("AudioFile.wav");
            URL configURL = edu.cmu.sphinx.demo.transcriber.Transcriber.class.getResource("config.xml");
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
                    stringline = stringline + ' ' + result.getBestResultNoFiller();
                    System.out.println(stringline);
            }
            return stringline;
        }
    }
    
    public File frombytes(byte[] bytesarray)       
    {
        File someFile = new File("name.wav");
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
