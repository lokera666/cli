// Generated by Ignite ignite.com/cli

import { StdFee } from "@cosmjs/launchpad";
import { SigningStargateClient, DeliverTxResponse } from "@cosmjs/stargate";
import { EncodeObject } from "@cosmjs/proto-signing";
import { msgTypes } from './registry';
import { IgniteClient } from "../client"
import { Api } from "./rest";
{{ range .Module.Msgs }}import { {{ .Name }} } from "./types/{{ resolveFile .FilePath }}";
{{ end }}

{{ range .Module.Msgs }}
type send{{ .Name }}Params = {
  value: {{ .Name }},
  fee?: StdFee,
  memo?: string
};
{{ end }}
{{ range .Module.Msgs }}
type {{ camelCase .Name }}Params = {
  value: {{ .Name }},
};
{{ end }}

class SDKModule extends Api<any> {
	private _client: SigningStargateClient;
	private _addr: string;
	public registry;

	constructor(client: IgniteClient) {
		super({
			baseUrl: client.env.apiURL
		})
		this._client = client.client;
		this._addr = client.env.rpcURL;
	}


	{{ range .Module.Msgs }}
	async send{{ .Name }}({ value, fee, memo }: send{{ .Name }}Params): Promise<DeliverTxResponse> {
		if (!this._client) {
		    throw new Error('TxClient:send{{ .Name }}: Unable to sign Tx. Signer is not present.')
		}
		if (!this._addr) {
            throw new Error('TxClient:send{{ .Name }}: Unable to sign Tx. Address is not present.')
        }
		try {
			let msg = this.{{ camelCase .Name }}({ value: {{ .Name }}.fromPartial(value) })
			return await this._client.signAndBroadcast(this._addr, [msg], fee ? fee : { amount: [], gas: '200000' }, memo)
		} catch (e: any) {
			throw new Error('TxClient:send{{ .Name }}: Could not broadcast Tx: '+ e.message)
		}
	}
	{{ end }}
	{{ range .Module.Msgs }}
	{{ camelCase .Name }}({ value }: {{ camelCase .Name }}Params): EncodeObject {
		try {
			return { typeUrl: "/{{ .URI }}", value: {{ .Name }}.fromPartial( value ) }  
		} catch (e: any) {
			throw new Error('TxClient:{{ .Name }}: Could not create message: ' + e.message)
		}
	}
	{{ end }}
};

const Module = (test: IgniteClient) => {
	return {
		module: {
			{{ camelCaseLowerSta .Module.Pkg.Name }}: new SDKModule(test)
		},
		registry: msgTypes
  }
}
export default Module;