import numpy as np

def generate_key(w,m,n):
    S = (np.random.rand(m,n) * w / (2 ** 16)) # proving max(S) < w
    return S

def encrypt(x,S,m,n,w):
    assert len(x) == len(S)
    
    e = (np.random.rand(m)) # proving max(e) < w / 2
    c = np.linalg.inv(S).dot((w * x) + e)
    return c

def decrypt(c,S,w):
    return (S.dot(c) / w).astype('int')

def get_c_star(c,m,l):
    c_star = np.zeros(l * m,dtype='int')
    for i in range(m):
        b = np.array(list(np.binary_repr(np.abs(c[i]))),dtype='int')
        if(c[i] < 0):
            b *= -1
        c_star[(i * l) + (l-len(b)): (i+1) * l] += b
    return c_star

def switch_key(c,S,m,n,T):
    l = int(np.ceil(np.log2(np.max(np.abs(c)))))
    c_star = get_c_star(c,m,l)
    S_star = get_S_star(S,m,n,l)
    n_prime = n + 1
    

    S_prime = np.concatenate((np.eye(m),T.T),0).T
    A = (np.random.rand(n_prime - m, n*l) * 10).astype('int')
    E = (1 * np.random.rand(S_star.shape[0],S_star.shape[1])).astype('int')
    M = np.concatenate(((S_star - T.dot(A) + E),A),0)
    c_prime = M.dot(c_star)
    return c_prime,S_prime

def get_S_star(S,m,n,l):
    S_star = list()
    for i in range(l):
        S_star.append(S*2**(l-i-1))
    S_star = np.array(S_star).transpose(1,2,0).reshape(m,n*l)
    return S_star

def get_T(n):
    n_prime = n + 1
    T = (10 * np.random.rand(n,n_prime - n)).astype('int')
    return T

def encrypt_via_switch(x,w,m,n,T):
    c,S = switch_key(x*w,np.eye(m),m,n,T)
    return c,S

x = np.array([0,1,2,5])

m = len(x)
n = m
w = 16
S = generate_key(w,m,n)

def sigmoid(layer_2_c):
    out_rows = list()
    for position in range(len(layer_2_c)-1):

        M_position = M_onehot[len(layer_2_c)-2][0]

        layer_2_index_c = innerProd(layer_2_c,v_onehot[len(layer_2_c)-2][position],M_position,l) / scaling_factor

        x = layer_2_index_c
        x2 = innerProd(x,x,M_position,l) / scaling_factor
        x3 = innerProd(x,x2,M_position,l) / scaling_factor
        x5 = innerProd(x3,x2,M_position,l) / scaling_factor
        x7 = innerProd(x5,x2,M_position,l) / scaling_factor

        xs = copy.deepcopy(v_onehot[5][0])
        xs[1] = x[0]
        xs[2] = x2[0]
        xs[3] = x3[0]
        xs[4] = x5[0]
        xs[5] = x7[0]

        out = mat_mul_forward(xs,H_sigmoid[0:1],scaling_factor)
        out_rows.append(out)
    return transpose(out_rows)[0]

def load_linear_transformation(syn0_text,scaling_factor = 1000):
    syn0_text *= scaling_factor
    return linearTransformClient(syn0_text.T,getSecretKey(T_keys[len(syn0_text)-1]),T_keys[len(syn0_text)-1],l)

def outer_product(x,y):
    flip = False
    if(len(x) < len(y)):
        flip = True
        tmp = x
        x = y
        y = tmp
        
    y_matrix = list()

    for i in range(len(x)-1):
        y_matrix.append(y)

    y_matrix_transpose = transpose(y_matrix)

    outer_result = list()
    for i in range(len(x)-1):
        outer_result.append(mat_mul_forward(x * onehot[len(x)-1][i],y_matrix_transpose,scaling_factor))
    
    if(flip):
        return transpose(outer_result)
    
    return outer_result

def mat_mul_forward(layer_1,syn1,scaling_factor):
    
    input_dim = len(layer_1)
    output_dim = len(syn1)

    buff = np.zeros(max(output_dim+1,input_dim+1))
    buff[0:len(layer_1)] = layer_1
    layer_1_c = buff
    
    syn1_c = list()
    for i in range(len(syn1)):
        buff = np.zeros(max(output_dim+1,input_dim+1))
        buff[0:len(syn1[i])] = syn1[i]
        syn1_c.append(buff)
    
    layer_2 = innerProd(syn1_c[0],layer_1_c,M_onehot[len(layer_1_c) - 2][0],l) / float(scaling_factor)
    for i in range(len(syn1)-1):
        layer_2 += innerProd(syn1_c[i+1],layer_1_c,M_onehot[len(layer_1_c) - 2][i+1],l) / float(scaling_factor)
    return layer_2[0:output_dim+1]

def elementwise_vector_mult(x,y,scaling_factor):
    
    y =[y]
    
    one_minus_layer_1 = transpose(y)

    outer_result = list()
    for i in range(len(x)-1):
        outer_result.append(mat_mul_forward(x * onehot[len(x)-1][i],y,scaling_factor))
        
    return transpose(outer_result)[0]

# HAPPENS ON SECURE SERVER

l = 100
w = 2 ** 25

aBound = 10
tBound = 10
eBound = 10

max_dim = 10

scaling_factor = 1000

# keys
T_keys = list()
for i in range(max_dim):
    T_keys.append(np.random.rand(i+1,1))

# one way encryption transformation
M_keys = list()
for i in range(max_dim):
    M_keys.append(innerProdClient(T_keys[i],l))

M_onehot = list()
for h in range(max_dim):
    i = h+1
    buffered_eyes = list()
    for row in np.eye(i+1):
        buffer = np.ones(i+1)
        buffer[0:i+1] = row
        buffered_eyes.append((M_keys[i-1].T * buffer).T)
    M_onehot.append(buffered_eyes)
    
c_ones = list()
for i in range(max_dim):
    c_ones.append(encrypt(T_keys[i],np.ones(i+1), w, l).astype('int'))
    
v_onehot = list()
onehot = list()
for i in range(max_dim):
    eyes = list()
    eyes_txt = list()
    for eye in np.eye(i+1):
        eyes_txt.append(eye)
        eyes.append(one_way_encrypt_vector(eye,scaling_factor))
    v_onehot.append(eyes)
    onehot.append(eyes_txt)

H_sigmoid_txt = np.zeros((5,5))

H_sigmoid_txt[0][0] = 0.5
H_sigmoid_txt[0][1] = 0.25
H_sigmoid_txt[0][2] = -1/48.0
H_sigmoid_txt[0][3] = 1/480.0
H_sigmoid_txt[0][4] = -17/80640.0

H_sigmoid = list()
for row in H_sigmoid_txt:
    H_sigmoid.append(one_way_encrypt_vector(row))


np.random.seed(1234)

input_dataset = [[],[0],[1],[0,1]]
output_dataset = [[0],[1],[1],[0]]

input_dim = 3
hidden_dim = 4
output_dim = 1
alpha = 0.015

# one way encrypt our training data using the public key (this can be done onsite)
y = list()
for i in range(4):
    y.append(one_way_encrypt_vector(output_dataset[i],scaling_factor))

# generate our weight values
syn0_t = (np.random.randn(input_dim,hidden_dim) * 0.2) - 0.1
syn1_t = (np.random.randn(output_dim,hidden_dim) * 0.2) - 0.1

# one-way encrypt our weight values
syn1 = list()
for row in syn1_t:
    syn1.append(one_way_encrypt_vector(row,scaling_factor).astype('int64'))

syn0 = list()
for row in syn0_t:
    syn0.append(one_way_encrypt_vector(row,scaling_factor).astype('int64'))


# begin training
for iter in range(1000):
    
    decrypted_error = 0
    encrypted_error = 0
    for row_i in range(4):

        if(row_i == 0):
            layer_1 = sigmoid(syn0[0])
        elif(row_i == 1):
            layer_1 = sigmoid((syn0[0] + syn0[1])/2.0)
        elif(row_i == 2):
            layer_1 = sigmoid((syn0[0] + syn0[2])/2.0)
        else:
            layer_1 = sigmoid((syn0[0] + syn0[1] + syn0[2])/3.0)

        layer_2 = (innerProd(syn1[0],layer_1,M_onehot[len(layer_1) - 2][0],l) / float(scaling_factor))[0:2]

        layer_2_delta = add_vectors(layer_2,-y[row_i])

        syn1_trans = transpose(syn1)

        one_minus_layer_1 = [(scaling_factor * c_ones[len(layer_1) - 2]) - layer_1]
        sigmoid_delta = elementwise_vector_mult(layer_1,one_minus_layer_1[0],scaling_factor)
        layer_1_delta_nosig = mat_mul_forward(layer_2_delta,syn1_trans,1).astype('int64')
        layer_1_delta = elementwise_vector_mult(layer_1_delta_nosig,sigmoid_delta,scaling_factor) * alpha

        syn1_delta = np.array(outer_product(layer_2_delta,layer_1)).astype('int64')

        syn1[0] -= np.array(syn1_delta[0]* alpha).astype('int64')

        syn0[0] -= (layer_1_delta).astype('int64')

        if(row_i == 1):
            syn0[1] -= (layer_1_delta).astype('int64')
        elif(row_i == 2):
            syn0[2] -= (layer_1_delta).astype('int64')
        elif(row_i == 3):
            syn0[1] -= (layer_1_delta).astype('int64')
            syn0[2] -= (layer_1_delta).astype('int64')


        # So that we can watch training, I'm going to decrypt the loss as we go.
        # If this was a secure environment, I wouldn't be doing this here. I'd send
        # the encrypted loss somewhere else to be decrypted
        encrypted_error += int(np.sum(np.abs(layer_2_delta)) / scaling_factor)
        decrypted_error += np.sum(np.abs(s_decrypt(layer_2_delta).astype('float')/scaling_factor))

    
    sys.stdout.write("\r Iter:" + str(iter) + " Encrypted Loss:" + str(encrypted_error) +  " Decrypted Loss:" + str(decrypted_error) + " Alpha:" + str(alpha))
    
    # just to make logging nice
    if(iter % 10 == 0):
        print()
    
    # stop training when encrypted error reaches a certain level
    if(encrypted_error < 25000000):
        break
        
print("\nFinal Prediction:")

for row_i in range(4):

    if(row_i == 0):
        layer_1 = sigmoid(syn0[0])
    elif(row_i == 1):
        layer_1 = sigmoid((syn0[0] + syn0[1])/2.0)
    elif(row_i == 2):
        layer_1 = sigmoid((syn0[0] + syn0[2])/2.0)
    else:
        layer_1 = sigmoid((syn0[0] + syn0[1] + syn0[2])/3.0)

    layer_2 = (innerProd(syn1[0],layer_1,M_onehot[len(layer_1) - 2][0],l) / float(scaling_factor))[0:2]
    print("True Pred:" + str(output_dataset[row_i]) + " Encrypted Prediction:" + str(layer_2) + " Decrypted Prediction:" + str(s_decrypt(layer_2) / scaling_factor))

import time
import sys
import numpy as np

# Let's tweak our network from before to model these phenomena
class SentimentNetwork:
    def __init__(self, reviews,labels,min_count = 10,polarity_cutoff = 0.1,hidden_nodes = 8, learning_rate = 0.1):
       
        np.random.seed(1234)
    
        self.pre_process_data(reviews, polarity_cutoff, min_count)
        
        self.init_network(len(self.review_vocab),hidden_nodes, 1, learning_rate)
        
        
    def pre_process_data(self,reviews, polarity_cutoff,min_count):
        
        print("Pre-processing data...")
        
        positive_counts = Counter()
        negative_counts = Counter()
        total_counts = Counter()

        for i in range(len(reviews)):
            if(labels[i] == 'POSITIVE'):
                for word in reviews[i].split(" "):
                    positive_counts[word] += 1
                    total_counts[word] += 1
            else:
                for word in reviews[i].split(" "):
                    negative_counts[word] += 1
                    total_counts[word] += 1

        pos_neg_ratios = Counter()

        for term,cnt in list(total_counts.most_common()):
            if(cnt >= 50):
                pos_neg_ratio = positive_counts[term] / float(negative_counts[term]+1)
                pos_neg_ratios[term] = pos_neg_ratio

        for word,ratio in pos_neg_ratios.most_common():
            if(ratio > 1):
                pos_neg_ratios[word] = np.log(ratio)
            else:
                pos_neg_ratios[word] = -np.log((1 / (ratio + 0.01)))
        
        review_vocab = set()
        for review in reviews:
            for word in review.split(" "):
                if(total_counts[word] > min_count):
                    if(word in pos_neg_ratios.keys()):
                        if((pos_neg_ratios[word] >= polarity_cutoff) or (pos_neg_ratios[word] <= -polarity_cutoff)):
                            review_vocab.add(word)
                    else:
                        review_vocab.add(word)
        self.review_vocab = list(review_vocab)
        
        label_vocab = set()
        for label in labels:
            label_vocab.add(label)
        
        self.label_vocab = list(label_vocab)
        
        self.review_vocab_size = len(self.review_vocab)
        self.label_vocab_size = len(self.label_vocab)
        
        self.word2index = {}
        for i, word in enumerate(self.review_vocab):
            self.word2index[word] = i
        
        self.label2index = {}
        for i, label in enumerate(self.label_vocab):
            self.label2index[label] = i
         
        
    def init_network(self, input_nodes, hidden_nodes, output_nodes, learning_rate):
        # Set number of nodes in input, hidden and output layers.
        self.input_nodes = input_nodes
        self.hidden_nodes = hidden_nodes
        self.output_nodes = output_nodes

        print("Initializing Weights...")
        self.weights_0_1_t = np.zeros((self.input_nodes,self.hidden_nodes))
    
        self.weights_1_2_t = np.random.normal(0.0, self.output_nodes**-0.5, 
                                                (self.hidden_nodes, self.output_nodes))
        
        print("Encrypting Weights...")
        self.weights_0_1 = list()
        for i,row in enumerate(self.weights_0_1_t):
            sys.stdout.write("\rEncrypting Weights from Layer 0 to Layer 1:" + str(float((i+1) * 100) / len(self.weights_0_1_t))[0:4] + "% done")
            self.weights_0_1.append(one_way_encrypt_vector(row,scaling_factor).astype('int64'))
        print("")
        
        self.weights_1_2 = list()
        for i,row in enumerate(self.weights_1_2_t):
            sys.stdout.write("\rEncrypting Weights from Layer 1 to Layer 2:" + str(float((i+1) * 100) / len(self.weights_1_2_t))[0:4] + "% done")
            self.weights_1_2.append(one_way_encrypt_vector(row,scaling_factor).astype('int64'))           
        self.weights_1_2 = transpose(self.weights_1_2)
        
        self.learning_rate = learning_rate
        
        self.layer_0 = np.zeros((1,input_nodes))
        self.layer_1 = np.zeros((1,hidden_nodes))
        
    def sigmoid(self,x):
        return 1 / (1 + np.exp(-x))
    
    
    def sigmoid_output_2_derivative(self,output):
        return output * (1 - output)
    
    def update_input_layer(self,review):

        # clear out previous state, reset the layer to be all 0s
        self.layer_0 *= 0
        for word in review.split(" "):
            self.layer_0[0][self.word2index[word]] = 1

    def get_target_for_label(self,label):
        if(label == 'POSITIVE'):
            return 1
        else:
            return 0
        
    def train(self, training_reviews_raw, training_labels):

        training_reviews = list()
        for review in training_reviews_raw:
            indices = set()
            for word in review.split(" "):
                if(word in self.word2index.keys()):
                    indices.add(self.word2index[word])
            training_reviews.append(list(indices))

        layer_1 = np.zeros_like(self.weights_0_1[0])

        start = time.time()
        correct_so_far = 0
        total_pred = 0.5
        for i in range(len(training_reviews_raw)):
            review_indices = training_reviews[i]
            label = training_labels[i]

            layer_1 *= 0
            for index in review_indices:
                layer_1 += self.weights_0_1[index]
            layer_1 = layer_1 / float(len(review_indices))
            layer_1 = layer_1.astype('int64') # round to nearest integer

            layer_2 = sigmoid(innerProd(layer_1,self.weights_1_2[0],M_onehot[len(layer_1) - 2][1],l) / float(scaling_factor))[0:2]

            if(label == 'POSITIVE'):
                layer_2_delta = layer_2 - (c_ones[len(layer_2) - 2] * scaling_factor)
            else:
                layer_2_delta = layer_2

            weights_1_2_trans = transpose(self.weights_1_2)
            layer_1_delta = mat_mul_forward(layer_2_delta,weights_1_2_trans,scaling_factor).astype('int64')

            self.weights_1_2 -= np.array(outer_product(layer_2_delta,layer_1))  * self.learning_rate

            for index in review_indices:
                self.weights_0_1[index] -= (layer_1_delta * self.learning_rate).astype('int64')

            # we're going to decrypt on the fly so we can watch what's happening
            total_pred += (s_decrypt(layer_2)[0] / scaling_factor)
            if((s_decrypt(layer_2)[0] / scaling_factor) >= (total_pred / float(i+2)) and label == 'POSITIVE'):
                correct_so_far += 1
            if((s_decrypt(layer_2)[0] / scaling_factor) < (total_pred / float(i+2)) and label == 'NEGATIVE'):
                correct_so_far += 1

            reviews_per_second = i / float(time.time() - start)

            sys.stdout.write("\rProgress:" + str(100 * i/float(len(training_reviews_raw)))[:4] + "% Speed(reviews/sec):" + str(reviews_per_second)[0:5] + " #Correct:" + str(correct_so_far) + " #Trained:" + str(i+1) + " Training Accuracy:" + str(correct_so_far * 100 / float(i+1))[:4] + "%")
            if(i % 100 == 0):
                print(i)

    
    def test(self, testing_reviews, testing_labels):
        
        correct = 0
        
        start = time.time()
        
        for i in range(len(testing_reviews)):
            pred = self.run(testing_reviews[i])
            if(pred == testing_labels[i]):
                correct += 1
            
            reviews_per_second = i / float(time.time() - start)
            
            sys.stdout.write("\rProgress:" + str(100 * i/float(len(testing_reviews)))[:4] \
                             + "% Speed(reviews/sec):" + str(reviews_per_second)[0:5] \
                            + "% #Correct:" + str(correct) + " #Tested:" + str(i+1) + " Testing Accuracy:" + str(correct * 100 / float(i+1))[:4] + "%")
    
    def run(self, review):
        
        # Input Layer


        # Hidden layer
        self.layer_1 *= 0
        unique_indices = set()
        for word in review.lower().split(" "):
            if word in self.word2index.keys():
                unique_indices.add(self.word2index[word])
        for index in unique_indices:
            self.layer_1 += self.weights_0_1[index]
        
        # Output layer
        layer_2 = self.sigmoid(self.layer_1.dot(self.weights_1_2))
        
        if(layer_2[0] >= 0.5):
            return "POSITIVE"
        else:
            return "NEGATIVE"
        

