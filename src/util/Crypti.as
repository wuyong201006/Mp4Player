package util
{
	import com.hurlant.crypto.Crypto;
	import com.hurlant.crypto.symmetric.ICipher;
	import com.hurlant.crypto.symmetric.IPad;
	import com.hurlant.crypto.symmetric.IVMode;
	import com.hurlant.crypto.symmetric.NullPad;
	import com.hurlant.util.Base64;
	import com.hurlant.util.Hex;
	
	import flash.utils.ByteArray;

	public class Crypti
	{
		public function Crypti()
		{
		}
		
		public static  function encrypt(keyStr:String, encryptStr:String):String
		{
			var key:ByteArray = Hex.toArray(keyStr);
			var data:ByteArray = Hex.toArray(encryptStr);
			var pad:IPad = new NullPad();
			var cipher:ICipher = Crypto.getCipher("des-cbc", key, pad);
			pad.setBlockSize(cipher.getBlockSize());
			cipher.encrypt(data);
			
			return Base64.encodeByteArray(data);
		}
		
		public static function decrypt(keyStr:String, decryptStr:String):String
		{
			var decrypt:ByteArray = Base64.decodeToByteArray(decryptStr);
			
			var key:ByteArray = Hex.toArray(keyStr);
			var pad:IPad = new NullPad();
			var cipher:ICipher = Crypto.getCipher("des-cbc", key, pad);
			pad.setBlockSize(cipher.getBlockSize());
			
			var iv:ByteArray = new ByteArray();
			if(cipher is IVMode)
			{
				var ivm:IVMode = cipher as IVMode;
				ivm.IV = iv;
			}
			cipher.decrypt(decrypt);
			
			return Hex.fromArray(decrypt);
		}
	}
}