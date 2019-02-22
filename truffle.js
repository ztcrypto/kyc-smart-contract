module.exports = {
   networks: {
   development: {
   host: "localhost",
   port: 8545,
   network_id: "*" // Match any network id
  }
 },
 compilers: {
   solc: {
     version: "0.4.24",  
     docker: true,
     settings: {
       optimizer: {
         enabled: true, 
         runs: 200    
       }
     }
   }
 }
};