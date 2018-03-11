import {Connect, SimpleSigner} from 'uport-connect'

const uport = new Connect('Cole Mecum\'s new app', {
  clientId: '2owkCpBm9SenzZhpnjJy5SRJEADQ6z9vszq',
  network: 'rinkeby or ropsten or kovan',
  signer: SimpleSigner('70a4d8d4c5e874662ac1820a025d0da7f0f1091fda3824902e4407ccdfa0b67f')
})

// Request credentials to login
uport.requestCredentials({
                           requested: ['name', 'phone', 'country'],
                           notifications: true // We want this if we want to recieve credentials
                         })
  .then((credentials) => {
    // Do something
  })

// Attest specific credentials
uport.attestCredentials({
                          sub: THE_RECEIVING_UPORT_ADDRESS,
                          claim: {
                            CREDENTIAL_NAME: CREDENTIAL_VALUE
                          },
                          exp: new Date().getTime() + 30 * 24 * 60 * 60 * 1000, // 30 days from now
                        })
export let uport = new Connect('TruffleBox')
export const web3 = uport.getWeb3()
