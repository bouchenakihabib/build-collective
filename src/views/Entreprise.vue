<template lang="html">
  <div class="home" v-if="!account">
    <form @submit.prevent="createEntreprise()">
        <card
            title="Enter your Entreprise name here"
            subtitle="Type directly in the input and hit enter. All spaces will be converted to _"
        >
         <input
          type="text"
          class="input-name"
          v-model="nameEntreprise"
          placeholder="Type your Entreprise name here"
         />
        </card>
    </form>
    </div>
    <div class="home" v-if="account">
    <div class="card-home-wrapper">
      <card
        :title="account.name"
        :subtitle="`${balance} Ξ\t\t${account.balance} Tokens`"
        :gradient="true"
      >
        <div class="explanations">
          This data has been fetched from the blockchain. You started by
          connecting MetaMask, and you fetched your data by reading the
          blockchain. Try to modify the code to see what's happening!
        </div>
        <div class="explanations">
          On your account on the contract, you have
          {{ account.balance }} tokens. If you click
          <button class="button-link" @click="addTokens">here</button>, you can
          add some token to your account. Just give it a try! And think to put
          an eye on Ganache!
        </div>
      </card>
    </div>
  </div>
</template>  

<script lang="ts">
import { defineComponent, computed } from 'vue'
import { useStore } from 'vuex'
import Card from '@/components/Card.vue'

export default defineComponent({
  components: { Card },
  setup() {
    const store = useStore()
    const address = computed(() => store.state.account.address)
    const balance = computed(() => store.state.account.balance)
    const contract = computed(() => store.state.contract)
    return { address, contract, balance }
  },
  data() {
    const account = null
    const nameEntreprise = ''
    return { account, nameEntreprise }
  },
  methods:{
      async updateAccount() {
      const { address, contract } = this
      this.account = await contract.methods.entreprise(address).call()
    },
    async createEntreprise() {
      const { contract, nameEntreprise } = this
      const nameEnt = nameEntreprise.trim().replace(/ /g, '_')
      await contract.methods.addEntreprise(nameEnt).send()
      await this.updateAccount()
      this.nameEntreprise=''
    },
    async addTokens() {
      const { contract } = this
      await contract.methods.addBalanceEntreprise(200).send()
      await this.updateAccount()
    },
  },
  async mounted() {
    const { address, contract } = this
    const account = await contract.methods.entreprise(address).call()
    if (account.registered) this.account = account
  },
})
</script>

<style lang="css" scoped>
.home {
  padding: 24px;
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
  max-width: 500px;
  margin: auto;
}

.explanations {
  padding: 12px;
}

.button-link {
  display: inline;
  appearance: none;
  border: none;
  background: none;
  color: inherit;
  text-decoration: underline;
  font-family: inherit;
  font-size: inherit;
  font-weight: inherit;
  padding: 0;
  margin: 0;
  cursor: pointer;
}

.input-name {
  background: transparent;
  border: none;
  padding: 12px;
  outline: none;
  width: 100%;
  color: white;
  font-family: inherit;
  font-size: 1.3rem;
}
</style>