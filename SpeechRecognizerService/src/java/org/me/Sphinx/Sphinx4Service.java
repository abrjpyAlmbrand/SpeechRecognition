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

import javax.sound.sampled.UnsupportedAudioFileException;
import java.io.IOException;
import java.net.URL;
/**
 *
 * @author Studentas
 */
@WebService(serviceName = "Sphinx4Service")
public class Sphinx4Service {

    /**
     * Web service operation
     */
    @WebMethod(operationName = "GetStringFromAudio")
    public String GetStringFromAudio() {
        String Text;
        Transcriber aaa = new Transcriber();
        try
        {
            Text = aaa.test();
        }
        catch(Exception e)
        {
            return null;
        }
        return Text;
    }
    
    public class Transcriber {
        
        public String test() throws IOException, UnsupportedAudioFileException {
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
}
