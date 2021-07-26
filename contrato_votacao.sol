// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

/// @title Sistema de Votação  
// O seguinte contrato tem como objetivo implementar um sistema de votação descentralizado.
contract sistemaVotacao {
	struct Eleitor {
		uint eleitorAtivo;	// indica se o eleitor está autorizado a votar
		bool votou; 		// indica se o eleitor já votou
		uint voto;  		// indica em qual candidato o eleitor votou
	}

	struct Candidatura {
		string nome;	// nome do candidato a eleição
		uint contVotos;	// quantidade de votos do candidato
	}

	uint contagemVotos;
	address public responsavel;	// entidade responsável pela eleição
	Candidatura[] public candidaturas;
	mapping(address => Eleitor) public eleitores;

	constructor() {
		contagemVotos = 0;
		responsavel = msg.sender;
		eleitores[responsavel].eleitorAtivo = 1;
		string[6] memory nomesCandidatos= ["NULO","Luiza","Marina","Luisa","Joao","David"];
		
		for (uint i = 0; i < nomesCandidatos.length; i++) {		
			candidaturas.push(Candidatura({
				nome: nomesCandidatos[i],
				contVotos: 0
			}));
		}
	}
	
	address[] public eleitoresAtivos;
	/* permite ao responsável pela votação distribuir aos outros participantes permissões para votar
	paramêtro:
		address eleitor -- eleitor a que será dada a permissão de voto.	*/
	function direitoVotar(address eleitor) public {
		require(
			msg.sender == responsavel,
			"Somente o responsavel pode dar o direito ao voto."
		);

		require(
			!eleitores[eleitor].votou,
			"Tentativa de voto duplicado."
		);

		require(eleitores[eleitor].eleitorAtivo == 0);
		eleitores[eleitor].eleitorAtivo = 1;
		eleitoresAtivos.push(eleitor);
	}

	/* contabiliza um voto a um determinado candidato
	parâmetro:
		unit candidato -- candidato para o qual irá o voto. */
	function votacao(uint candidato) public {	
		Eleitor storage sender = eleitores[msg.sender];

		require(sender.eleitorAtivo != 0, "Eleitor sem permissao para votar.");
		require(!sender.votou, "Tentativa de voto duplicado.");

		sender.votou = true;
		sender.voto = candidato;
		candidaturas[candidato].contVotos += sender.eleitorAtivo;
		contagemVotos++;
	}

	/* determina candidato eleito
	retorno:
		unit candidatoEleito --  candidato eleito. */
	function obterCandEleito() public view
			returns (uint candidatoEleito)
	{
		require(contagemVotos > 0, "Nenhum voto computado.");
		
		bool ehEmpate = false;
		uint valorEmpate = 0;
		
		uint contadorVotosEleito = 0;
		for (uint c = 0; c < candidaturas.length; c++) {
			if (candidaturas[c].contVotos >= contadorVotosEleito) {
				contadorVotosEleito = candidaturas[c].contVotos;
				candidatoEleito = c;
				if (candidaturas[c].contVotos == contadorVotosEleito) {
					ehEmpate = true;
					valorEmpate = candidaturas[c].contVotos;
				}
			}
		}
		
		require(ehEmpate == false || valorEmpate < contadorVotosEleito, "Empate.");
		require(candidatoEleito != 0, "Votação anulada.");

	}

	/* retorna o nome do candidato eleito
	retorno:
		string memory nomeEleito -- nome do candidato eleito. */
	function eleitoNome() public view
			returns (string memory nomeEleito)
	{
		nomeEleito = candidaturas[obterCandEleito()].nome;
	}	
}