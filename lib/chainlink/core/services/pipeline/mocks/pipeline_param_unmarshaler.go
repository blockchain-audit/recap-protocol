// Code generated by mockery v2.14.0. DO NOT EDIT.

package mocks

import mock "github.com/stretchr/testify/mock"

// PipelineParamUnmarshaler is an autogenerated mock type for the PipelineParamUnmarshaler type
type PipelineParamUnmarshaler struct {
	mock.Mock
}

// UnmarshalPipelineParam provides a mock function with given fields: val
func (_m *PipelineParamUnmarshaler) UnmarshalPipelineParam(val interface{}) error {
	ret := _m.Called(val)

	var r0 error
	if rf, ok := ret.Get(0).(func(interface{}) error); ok {
		r0 = rf(val)
	} else {
		r0 = ret.Error(0)
	}

	return r0
}

type mockConstructorTestingTNewPipelineParamUnmarshaler interface {
	mock.TestingT
	Cleanup(func())
}

// NewPipelineParamUnmarshaler creates a new instance of PipelineParamUnmarshaler. It also registers a testing interface on the mock and a cleanup function to assert the mocks expectations.
func NewPipelineParamUnmarshaler(t mockConstructorTestingTNewPipelineParamUnmarshaler) *PipelineParamUnmarshaler {
	mock := &PipelineParamUnmarshaler{}
	mock.Mock.Test(t)

	t.Cleanup(func() { mock.AssertExpectations(t) })

	return mock
}
