class Ethereum {
    constructor(contract, account) {
        this.contract = contract
        this.account = account
    }
    async getImage (id) {
        return await this.contract.methods.images(id).call({ from: this.account })
    }

    async buyImage (title, url) {
        return await this.contract.methods.buyImage(title, url).send({ from: this.account, value: 10**18 })
    }

    async getAllImages () {
        return (await this.contract.methods.getAllImages().call({ from: this.account })).filter((x) => x.is_claimed)
    }
}

export default Ethereum