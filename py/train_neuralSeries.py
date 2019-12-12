bnf =   """
<model_name>        ::= sample<member_no>.nn
<max_hnodes>        ::= 40
<node_type>         ::= sigmoid | linear | tanh
<positive-real>     ::= 0.<int-const>
<int-const>         ::= <int-const> | 1 | 2 | 3 | 4 | 5 | 6 |
                        7 | 8 | 9 | 0
<sign>              ::= + | -
<max_epochs>        ::= 1000
<starting_weight>   ::= <sign> 0.<int-const> | <sign> 1.<int-const> |
                        <sign> 2.<int-const> | <sign> 3.<int-const> |
                        <sign> 4.<int-const> | <sign> 5.<int-const>
<learn_rate>        ::= 0.<int-const>
<saved_name>        ::= None
<S>                 ::=
import math
import random

from pyneurgen.neuralnet import NeuralNet
from pyneurgen.nodes import Node, BiasNode, CopyNode, Connection
from pyneurgen.layers import Layer
from pyneurgen.recurrent import JordanRecurrent

net = NeuralNet()
hidden_nodes = max(int(round(<positive-real> * float(<max_hnodes>))), 1)

net.init_layers(len(self.all_inputs[0]),
                [hidden_nodes],
                len(self.all_targets[0]))

net.layers[1].set_activation_type('<node_type>')
net.output_layer.set_activation_type('<node_type>')

#   Use the genotype to get starting weights
for layer in net.layers[1:]:
    for node in layer.nodes:
        for conn in node.input_connections:
            #   every time it is asked, another starting weight is given
            conn.set_weight(self.runtime_resolve('<starting_weight>', 'float'))

# Note the injection of data from the genotype
# In a real project, the genotype might pull the data from elsewhere.
net.set_all_inputs(self.all_inputs)
net.set_all_targets(self.all_targets)

length = len(self.all_inputs)
learn_end_point = int(length * .6)
validation_end_point = int(length * .8)

net.set_learn_range(0, learn_end_point)

net.set_validation_range(0, learn_end_point)
net.set_validation_range(learn_end_point + 1, validation_end_point)
net.set_test_range(validation_end_point + 1, length - 1)

net.set_learnrate(<learn_rate>)
epochs = int(round(<positive-real> * float(<max_epochs>)))

if epochs > 0:
    #   Use learning to further set the weights
    net.learn(epochs=epochs, show_epoch_results=True,
        random_testing=False)

#   Use validation for generating the fitness value
mse = net.validate(show_sample_interval=0)

print "mse", mse
modelname = self.runtime_resolve('<model_name>', 'str')

net.save(modelname)

self.set_bnf_variable('<saved_name>', modelname)

#   This method can be used to look at all the particulars
#       of what happened...uses disk space
self.net = net
fitness = mse
self.set_bnf_variable('<fitness>', fitness)

            """
import pyneurgen.grammatical_evolution as pge
import pyneurgen.fitness as pfe
ges = pge.GrammaticalEvolution()

ges.set_bnf(bnf)
ges.set_genotype_length(start_gene_length=100,
                        max_gene_length=200)

ges.set_population_size(20)
ges.set_max_generations(50)
ges.set_fitness_type('center', 0.01)

ges.set_max_program_length(4000)

ges.set_wrap(True)
ges.set_fitness_fail(2.0)
ges.set_mutation_type('m')
ges.set_max_fitness_rate(.25)
ges.set_mutation_rate(.025)
ges.set_fitness_selections(
    pfe.FitnessElites(ges.fitness_list, .05),
    pfe.FitnessTournament(ges.fitness_list, tournament_size=2))

ges.set_crossover_rate(.2)
ges.set_children_per_crossover(2)

ges.set_replacement_selections(
    pfe.ReplacementTournament(ges.fitness_list, tournament_size=3))

ges.set_maintain_history(True)
ges.set_timeouts(10, 360)
#   All the parameters have been set.
ges.create_genotypes()

#   all samples are drawn from this population
pop_len = 200
factor = 1.0 / float(pop_len)
population = [[i, math.sin(float(i) * factor * 10.0) + \
                random.gauss(factor, .2)]
                    for i in range(pop_len)]

all_inputs = []
all_targets = []

def population_gen(population):
    """
    This function shuffles the values of the population and yields the
    items in a random fashion.

    """

    pop_sort = [item for item in population]
    random.shuffle(pop_sort)

    for item in pop_sort:
        yield item

#   Build the inputs
for position, target in population_gen(population):
    all_inputs.append([float(position) / float(pop_len), random.random()])
    all_targets.append([target])

for g in ges.population:
    g.all_inputs = all_inputs
    g.all_targets = all_targets


print ges.run()
print "Final Fitness list sorted best to worst:"
print ges.fitness_list.sorted()
print
print
g = ges.population[ges.fitness_list.best_member()]
program = g.local_bnf['program']

saved_model = g.local_bnf['<saved_name>'][0]

#   We will create a brand new model
net = NeuralNet()
net.load(saved_model)


test_positions = [item[0][0] for item in net.get_test_data()]
all_targets1 = [item[0][0] for item in net.test_targets_activations]
all_actuals = [item[1][0] for item in net.test_targets_activations]
#   This is quick and dirty, but it will show the results
plt.subplot(3, 1, 1)
plt.plot([i for i in sDay['y']],'-')
plt.title("Population")
plt.grid(True)
    
plt.subplot(3, 1, 2)
plt.plot(test_positions, all_targets1, 'bo', label='targets')
plt.plot(test_positions, all_actuals, 'ro', label='actuals')
plt.grid(True)
plt.legend(loc='lower left', numpoints=1)
plt.title("Test Target Points vs Actual Points")

plt.subplot(3, 1, 3)
plt.plot(range(1, len(net.accum_mse) + 1, 1), net.accum_mse)
plt.xlabel('epochs')
plt.ylabel('mean squared error')
plt.grid(True)
plt.title("Mean Squared Error by Epoch")
plt.show()

