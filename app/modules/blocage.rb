
	class Blocage

		# Constructeur
		def initialize(num)
			$num = num
			if $tableau.class != Array
				$tableau = Array.new
			end
		end

		# PERMET D'AJOUTER UN NUMERO A UNE LISTE
		# @params [Integer] num
		def self.add
			if $num.in?($tableau)
				return "Ce numero existe deja dans votre liste"
			else
				$tableau.push($num)
				puts "contenu du tableau apres ajout : #{$tableau}"
				return "Numero #{$num} a été ajouté à votre liste"
			end
		end

		# PERMET D'AJOUTER UN NUMERO A UNE LISTE
		# @params [Integer] num
		def self.search(num)
			@num = num
			if @num.in?($tableau)
				return true #"Ce numero existe dans votre liste"
			else
				return false #"ce numero ne figure pas dans votre liste"
			end
		end

		# PERMET D'AJOUTER UN NUMERO A UNE LISTE
		# @params [Integer] num
		def self.delete(num)
			@num = num
			#verifier l'element a supprimer est present
			elem = @num.in?($tableau)
			if elem
				result = $tableau.find_index(@num)
				if result.nil?
					return "Numero #{@num} non trouvé de votre liste"
				else
					#supprimer l'element en question
					status = $tableau.delete_at(result)
					return "Le numero #{@num} supprimé avec succes de votre liste"
				end
			else
				return "Ce numero n'existe pas dans votre liste"
			end
		end

		# MODIFIER UN NUMERO
		# @params [Integer] num
		def self.edit
		end

		# LISTER LES ELEMENTS D'UN TABLEAU
		def self.list
			puts "Votre liste comprend : #{$tableau}"
		end
	end