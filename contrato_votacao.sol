// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.4.22;

// Sistema de Votação 
// O seguinte contrato tem como objetivo implementar um sistema de votação descentralizado.
contract sistemaVotacao {
    
    
    struct Candidatura {
		string nome;	// nome do candidato a eleição
		uint contVotos;	// quantidade de votos do candidato
	}

	
	struct Eleitor {
	    uint voto;  		// indica em qual candidato o eleitor votou
		bool votou; 		// indica se o eleitor já votou
		bool eleitorAtivo;	// indica se o eleitor está autorizado a votar

	}

	address public responsavel;	// entidade responsável pela eleição

	uint contagemVotos;
		
	Candidatura[] public candidaturas;
	
	mapping(address => Eleitor) public eleitores;

	constructor() {
		
		contagemVotos = 0;
		
		responsavel = msg.sender;
		eleitores[responsavel].eleitorAtivo = true;
		
		string[6] memory nomesCandidatos= ["NULO","Luiza","Marina","Luisa","Joao","David"];
		
		for (uint i = 0; i < nomesCandidatos.length; i++) {		
			
		    Candidatura	memory novoCandidato = Candidatura({ nome: nomesCandidatos[i],contVotos: 0});
			candidaturas.push(novoCandidato);
		}
	}
	
	
	address[] public eleitoresAtivos;
	
	/* permite ao responsável pela votação distribuir aos outros participantes permissões para votar
	paramêtro:
		address eleitor -- eleitor a que será dada a permissão de voto.	*/
	function direitoVotar(address eleitor) external {
		require(
			msg.sender == responsavel,
			"Somente o responsavel pode dar o direito ao voto."
		);

		require(
			eleitores[eleitor].votou == false,
			"Tentativa de voto duplicado."
		);

		require(
		    eleitores[eleitor].eleitorAtivo == false,
		    "O eleitor nao pode estar ativo antes de ganhar o direito do voto."
		);
		
		eleitores[eleitor].eleitorAtivo = true;
		eleitoresAtivos.push(eleitor);
	}

	/* contabiliza um voto a um determinado candidato
	parâmetro:
		unit candidato -- candidato para o qual irá o voto. */
	function votacao(uint candidato) external {	
		
		Eleitor storage emissor = eleitores[msg.sender];

		require(
		    emissor.eleitorAtivo == true,
		    "Eleitor sem permissao para votar."
		);
		
		require(
		    emissor.votou == false, 
		    "Tentativa de voto duplicado."
		);
        
        contagemVotos++;
        
		emissor.votou = true;
		emissor.voto = candidato;
		candidaturas[candidato].contVotos += 1;
	}

	/* determina candidato eleito
	retorno:
		unit candidatoEleito --  candidato eleito. */
	function obterCandEleito() external view
			returns (string memory nomeEleito)
	{
		require(
		    contagemVotos > 0, 
		    "Nenhum voto computado."
		);
		
		bool ehEmpate = false;
		uint valorEmpate = 0;
		uint candidatoEleito;
		
		uint contadorVotosEleito = 0;
		for (uint c = 0; c < candidaturas.length; c++) {
		    
			if (candidaturas[c].contVotos >= contadorVotosEleito) {
			  
				if (candidaturas[c].contVotos == contadorVotosEleito) {
					
					ehEmpate = true;
					valorEmpate = candidaturas[c].contVotos;
				}
				contadorVotosEleito = candidaturas[c].contVotos;
				candidatoEleito = c;
			}
		}
		
		require(
		    ehEmpate == false || valorEmpate < contadorVotosEleito,
		    "Empate."
		);
		
		require(
		    candidatoEleito != 0,
		    "Votacao anulada."
		);
		
		nomeEleito = candidaturas[candidatoEleito].nome;

	}
	
}
