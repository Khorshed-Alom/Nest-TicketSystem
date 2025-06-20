package ethkey

import (
	"bytes"
	"crypto/ecdsa"
	"crypto/rand"
	"fmt"
	"math/big"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/crypto"

	"github.com/smartcontractkit/chainlink-evm/pkg/types"

	"github.com/smartcontractkit/chainlink/v2/core/services/keystore/internal"
)

var curve = crypto.S256()

func KeyFor(raw internal.Raw) KeyV2 {
	var privateKey ecdsa.PrivateKey
	d := big.NewInt(0).SetBytes(raw.Bytes())
	privateKey.PublicKey.Curve = curve
	privateKey.D = d
	privateKey.PublicKey.X, privateKey.PublicKey.Y = curve.ScalarBaseMult(d.Bytes())
	address := crypto.PubkeyToAddress(privateKey.PublicKey)
	eip55 := types.EIP55AddressFromAddress(address)
	return KeyV2{
		Address:      address,
		EIP55Address: eip55,
		privateKey:   &privateKey,
	}
}

var _ fmt.GoStringer = &KeyV2{}

type KeyV2 struct {
	Address      common.Address
	EIP55Address types.EIP55Address
	privateKey   *ecdsa.PrivateKey
}

func NewV2() (KeyV2, error) {
	privateKeyECDSA, err := ecdsa.GenerateKey(crypto.S256(), rand.Reader)
	if err != nil {
		return KeyV2{}, err
	}
	return FromPrivateKey(privateKeyECDSA), nil
}

func FromPrivateKey(privKey *ecdsa.PrivateKey) (key KeyV2) {
	address := crypto.PubkeyToAddress(privKey.PublicKey)
	eip55 := types.EIP55AddressFromAddress(address)
	return KeyV2{
		Address:      address,
		EIP55Address: eip55,
		privateKey:   privKey,
	}
}

func (key KeyV2) ID() string {
	return key.Address.Hex()
}

func (key KeyV2) Raw() internal.Raw {
	return internal.NewRaw(key.privateKey.D.Bytes())
}

func (key KeyV2) ToEcdsaPrivKey() *ecdsa.PrivateKey {
	return key.privateKey
}

func (key KeyV2) String() string {
	return fmt.Sprintf("EthKeyV2{PrivateKey: <redacted>, Address: %s}", key.Address)
}

func (key KeyV2) GoString() string {
	return key.String()
}

// Cmp uses byte-order address comparison to give a stable comparison between two keys
func (key KeyV2) Cmp(key2 KeyV2) int {
	return bytes.Compare(key.Address.Bytes(), key2.Address.Bytes())
}
