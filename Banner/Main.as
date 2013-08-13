package 
{
	import flash.display.Sprite;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.media.Microphone;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.system.Security;
	import org.bytearray.micrecorder.*;
	import org.bytearray.micrecorder.events.RecordingEvent;
	import org.bytearray.micrecorder.encoder.WaveEncoder;
	import org.as3wavsound.WavSound;
	import flash.events.*;
	import flash.utils.*;
	import mx.rpc.soap.*;
	import mx.rpc.events.*;
	import mx.rpc.AbstractOperation;
	import cmodule.flac.CLibInit;


	public class Main extends Sprite
	{
		var mic:Microphone;
		var waveEncoder:WaveEncoder = new WaveEncoder  ;
		var recorder:MicRecorder = new MicRecorder(waveEncoder);

		public var responseFromGoogle:ResponseAPI = new ResponseAPI  ;
		public var responseFromSphinx:ResponseSphinx = new ResponseSphinx  ;

		var sphinxService:WebService;
		var serviceOperation:AbstractOperation;
		var activity:int = new int  ;
		var entered:Boolean = new Boolean  ;

		var soundBytes:ByteArray = new ByteArray();
		static const FLOAT_MAX_VALUE:Number = 1.0;
		static const SHORT_MAX_VALUE:int = 0x7fff;
		var rawData: ByteArray = new ByteArray();
		var flacData : ByteArray = new ByteArray();
		var urlRequest:URLRequest;
		var urlLoader:URLLoader = new URLLoader();

		var player:WavSound;
		var channel:SoundChannel;
		var delay:uint = 30000;

		var repeat:uint = 1;
		var sphinxTimer:Timer = new Timer(delay,repeat);
		var sphinxStartTime:int;
		var googleTimer:Timer = new Timer(delay,repeat);
		var googleStartTime:int;;
		var recordTime:int;

		var timer:uint;

		public function Main():void
		{
			playbtn.visible = false;
			mic = Microphone.getMicrophone();
			mic.setSilenceLevel(0);
			mic.gain = 60;
			mic.setUseEchoSuppression(true);
			mic.rate = 16;
			entered = true;
			activity = 10;
			addListeners();
		}

		private function addListeners():void
		{
			recorder.addEventListener(RecordingEvent.RECORDING,recording);
			recorder.addEventListener(Event.COMPLETE,sendRequests);
			responseFromSphinx.addEventListener(Event.ENTER_FRAME,activeSound);
			startRecording();
		}
		private function startRecording():void
		{
			if ((mic != null))
			{
				recorder.record();

			}
		}

		private function activeSound(e:Event):void
		{
			if (mic.activityLevel > activity + 10)
			{
				activity = mic.activityLevel;
				entered = false;
			}
			if (mic.activityLevel < 8 && entered == false)
			{
				entered = true;
				timer = setTimeout(stopRecording,1500);
			}
		}
		private function stopRecording():void
		{
			recorder.stop();
			rec.txt.text = "...";
			addChild(rec);
		}
		function sendRequests(e:Event):void
		{
			if (entered == true)
			{
				EncoderForGoogle();
				InitSphinxService();
				playbtn.visible = true;
				playbtn.addEventListener(MouseEvent.CLICK,onPlay);
			}
		}

		private function recording(e:RecordingEvent):void
		{
			rec.txt.text = "Recording...";
			addChild(rec);
			if (e.time > 15000)
			{
				startRecording();
			}
			recordTime = e.time;
			playbtn.visible = false;
		}

		function InitSphinxService():void
		{
			sphinxService = new WebService  ;
			sphinxService.loadWSDL("http://fe531b79fb5842daacdcfbaa0c39104a.cloudapp.net/SpeechRecognizerServiseForTomCat/Sphinx4Service?wsdl");
			sphinxService.addEventListener(LoadEvent.LOAD,BuildServiceRequest);
		}
		function BuildServiceRequest(e:LoadEvent)
		{
			serviceOperation = sphinxService.getOperation("GetStringFromAudio");
			serviceOperation.addEventListener(FaultEvent.FAULT,DisplaySphinxError);
			serviceOperation.addEventListener(ResultEvent.RESULT,DisplaySphinxResult);
			soundBytes.position = 0;
			serviceOperation.send(recorder.output);
			sphinxTimer.start();
			sphinxStartTime = getTimer();
		}

		function DisplaySphinxError(e:FaultEvent)
		{
			responseFromSphinx.rec.text = e.fault.faultString;
			addChild(responseFromSphinx);
		}
		function DisplaySphinxResult(e:ResultEvent)
		{
			var sphinxCurrentTime:int = getTimer();
			sphinxTimer.stop();
			if ((e.result != null))
			{
				responseFromSphinx.rec.text = "Sphinx: " + (sphinxCurrentTime - sphinxStartTime) + "ms" + "  " + e.result;
				entered = true;
				activity = 10;
			}
			else
			{
				responseFromSphinx.rec.text = "null";
			}
			addChild(responseFromSphinx);
		}
		function onPlay(evt:MouseEvent=null):void
		{
			player = new WavSound(recorder.output);
			channel = player.play();
			channel.addEventListener(Event.SOUND_COMPLETE ,RestartRecordinge);

		}
		function RestartRecordinge(e:Event)
		{
			rec.txt.text = "Playing...";
			addChild(rec);
			timer = setTimeout(startRecording,recordTime + 1000);
		}
		function EncoderForGoogle():void
		{
			var flacCodec:Object;
			flacCodec = (new cmodule.flac.CLibInit).init();
			recorder.output2.position = 0;
			rawData = convert32to16(recorder.output2);
			flacData.endian = Endian.LITTLE_ENDIAN;
			flacCodec.encode(encodingCompleteHandler, encodingProgressHandler, rawData, flacData, rawData.length, 30);
		}
		function InitGoogleService():void
		{
			sphinxService = new WebService  ;
			sphinxService.loadWSDL("http://fe531b79fb5842daacdcfbaa0c39104a.cloudapp.net/SpeechRecognizerServiseForTomCat/Sphinx4Service?wsdl");
			sphinxService.addEventListener(LoadEvent.LOAD,BuildGoogleServiceRequest);
		}
		function BuildGoogleServiceRequest(e:LoadEvent)
		{
			serviceOperation = sphinxService.getOperation("GetStringFromGoogle");
			serviceOperation.addEventListener(FaultEvent.FAULT,DisplayGoogleError);
			serviceOperation.addEventListener(ResultEvent.RESULT,DisplayGoogleResult);
			serviceOperation.send(flacData);
			googleTimer.start();
			googleStartTime = getTimer();
		}

		function DisplayGoogleError(e:FaultEvent)
		{
			responseFromGoogle.rec.text = e.fault.faultString;
			addChild(responseFromGoogle);
		}
		function DisplayGoogleResult(e:ResultEvent)
		{
			var googleCurrentTime:int = getTimer();
			googleTimer.stop();
			if ((e.result != null))
			{
				responseFromGoogle.rec.text ="Google: " + (googleCurrentTime - googleStartTime) + "ms" + "  " + e.result;;
				entered = true;
				activity = 10;
			}
			else
			{
				responseFromGoogle.rec.text = "null";
			}
			addChild(responseFromGoogle);
		}

		function encodingCompleteHandler(event:*):void
		{
			InitGoogleService();
		}
		function encodingProgressHandler(progress:int):void
		{
			trace("FLACCodec.encodingProgressHandler(event):", progress);
		}

		function convert32to16(source:ByteArray):ByteArray
		{
			var result:ByteArray = new ByteArray();
			result.endian = Endian.LITTLE_ENDIAN;

			while ( source.bytesAvailable )
			{
				var sample:Number = source.readFloat() * SHORT_MAX_VALUE;
				if (sample < -SHORT_MAX_VALUE)
				{
					sample =  -  SHORT_MAX_VALUE;
				}
				else if (sample > SHORT_MAX_VALUE)
				{
					sample = SHORT_MAX_VALUE;

				}
				result.writeShort(sample);
			}
			result.position = 0;
			return result;
		}


	}
}